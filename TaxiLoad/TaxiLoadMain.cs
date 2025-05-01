using CsvHelper;
using Npgsql;
using System.Globalization;
using TaxiCommon;
using TaxiLoad;

namespace TaxiSplit
{
	internal class TaxiLoadMain
	{
		private static readonly int BatchSize = 50000;
		private static readonly string ConnectionString = "Host=localhost;Username=postgres;Password=SalaKala123#;Database=taxidb";

		static void Main(string[] args)
		{
			//TestConnection();

			Console.WriteLine($"Loading from {Consts.WeeklyDir}");


			foreach (var fileName in Directory.GetFiles(Consts.WeeklyDir))
			{
				var fileInfo = new FileInfo(fileName);
				var ftime = RoundDateToSecond(File.GetLastWriteTime(fileName));

				Console.WriteLine($"File: '{fileName}', Length: {fileInfo.Length}, Last Write Time: {ftime}");

				var loadInfos = GetFileLoadInfo(fileName);

				// Not loaded yet
				if (loadInfos == null || loadInfos.Count == 0)
				{
					LoadFile(fileName, fileInfo, ftime);
					continue;
				}

				// Loaded once or more 
				Console.WriteLine($"File '{fileName}' has been loaded {loadInfos.Count} times.");

				var lastLoadInfo = loadInfos[loadInfos.Count - 1];
				var checkMessages = new List<string>();

				if (lastLoadInfo.FileSize != fileInfo.Length)
					checkMessages.Add($"Last load size {lastLoadInfo.FileSize} <> current size {fileInfo.Length}.");

				if (!lastLoadInfo.FileTime.Equals(ftime))
					checkMessages.Add($"Recorded file time {lastLoadInfo.FileTime} <> current file time {ftime}. {Math.Abs((lastLoadInfo.FileTime - ftime).TotalSeconds)}");

				// Reload when discrepancies to time/size
				if (checkMessages.Count > 0)
				{
					Console.WriteLine($"Checks failing '{checkMessages.Count}: {string.Join(",", checkMessages)}'. Reloading");
					LoadFile(fileName, fileInfo, ftime);
				}
				else
					Console.WriteLine($"No checks failing. Skipping.");
			}
		}

		private static DateTime RoundDateToSecond(DateTime dt)
		{
			return new DateTime(dt.Year, dt.Month, dt.Day, dt.Hour, dt.Minute, dt.Second);
		}


		private static void TestConnection()
		{
			using (var connection = new NpgsqlConnection(ConnectionString))
			{
				connection.Open();

				using (var command = new NpgsqlCommand("SELECT * FROM Taxi.TaxiRides limit 1", connection))
				using (var reader = command.ExecuteReader())
				{
					while (reader.Read())
					{
						Console.WriteLine(reader.GetString(0));
						Console.WriteLine(reader.GetString(1));
						Console.WriteLine(reader.GetDateTime(2));
						Console.WriteLine(reader.GetDateTime(3));
					}
				}
			}
		}

		private static List<TaxiFileLoadRec> GetFileLoadInfo(string fileName)
		{
			var query = "SELECT fileid,filesize,filetime,loadstart,loadend, rowsread" +
				$" FROM taxi.taxifileload WHERE filename = '{fileName}' ORDER BY loadstart";

			using (var connection = new NpgsqlConnection(ConnectionString))
			{
				connection.Open();

				using var command = new NpgsqlCommand(query, connection);
				using var reader = command.ExecuteReader();

				var records = new List<TaxiFileLoadRec>();
				while (reader.Read())
				{
					records.Add(new TaxiFileLoadRec()
					{
						FileId = reader.GetInt64(0),
						FileName = fileName,
						FileSize = reader.GetInt64(1),
						FileTime = RoundDateToSecond(reader.GetDateTime(2)),
						LoadStart = reader.GetDateTime(3),
						LoadEnd = reader.GetDateTime(4),
						RowsRead = reader.GetInt64(5)
					});

				}

				return records;
			}
		}

		private static void SaveFileLoadInfo(string fileName, FileInfo fileInfo
			, DateTime lastWriteTime, DateTime loadStart, DateTime loadEnd, long rowsRead)
		{
			Console.WriteLine($"Marking file {fileName} loaded");

			var sqlStr = "INSERT INTO taxi.taxifileload(filename, filesize, filetime, loadstart, loadend, rowsread) " +
						 "VALUES (@filename, @filesize, @filetime, @loadstart, @loadend, @rowsread)";

			using (var connection = new NpgsqlConnection(ConnectionString))
			{
				connection.Open();

				using (var cmd = new NpgsqlCommand(sqlStr, connection))
				{
					cmd.Parameters.AddWithValue("@filename", fileName);
					cmd.Parameters.AddWithValue("@filesize", fileInfo.Length);
					cmd.Parameters.AddWithValue("@filetime", lastWriteTime);
					cmd.Parameters.AddWithValue("@loadstart", loadStart);
					cmd.Parameters.AddWithValue("@loadend", loadEnd);
					cmd.Parameters.AddWithValue("@rowsread", rowsRead);

					cmd.ExecuteNonQuery();
				}
			}

		}

		private static void LoadFile(string fileName, FileInfo fileInfo, DateTime lastWriteTime)
		{
			Console.WriteLine($"Loading: {fileName}");
			var rowsRead = 0;
			var RecordCache = new List<TaxiRideRec>(BatchSize);

			var loadStart = DateTime.Now;
			using (var fileStream = File.OpenRead(fileName))
			using (BufferedStream bufRead = new BufferedStream(fileStream, 5 * 1048576))
			using (var strmRead = new StreamReader(bufRead))
			using (var csv = new CsvReader(strmRead, CultureInfo.InvariantCulture))
			{
				while (csv.Read())
				{
					rowsRead++;
					RecordCache.Add(csv.GetRecord<TaxiRideRec>());
					if (rowsRead % BatchSize == 0)
					{
						Console.WriteLine($"Row {rowsRead}. Flushing");
						FlushCache(RecordCache);
					}
				}
			}
			Console.WriteLine($"Row {rowsRead}. Flushing");
			FlushCache(RecordCache);

			var loadEnd = DateTime.Now;

			// Save load status
			SaveFileLoadInfo(fileName: fileName, fileInfo: fileInfo, lastWriteTime: lastWriteTime
				, loadStart: loadStart, loadEnd: loadEnd, rowsRead: rowsRead);
		}


		private static void FlushCache(List<TaxiRideRec> recordCache)
		{
			if (recordCache.Count == 0)
				return;

			Console.WriteLine($"Flushing {recordCache.Count} records to db");

			using (var connection = new NpgsqlConnection(ConnectionString))
			{
				connection.Open();

				var sqlStr = FormSqlUpsert(recordCache);
				using (var cmd = new NpgsqlCommand(cmdText: sqlStr, connection: connection))
				{
					cmd.ExecuteNonQuery();
				}
			}
			recordCache.Clear();
		}

		private static string FormSqlUpsert(List<TaxiRideRec> recordCache)
		{
			var valSecLst = new List<string>(recordCache.Count);

			foreach (var rec in recordCache)
				valSecLst.Add(rec.SqlValues());

			return @$"MERGE INTO Taxi.TaxiRides AS r
		USING (
		VALUES 
			{string.Join(',', valSecLst)}
		) AS v (TripId, TaxiId, TripStart, TripEnd, TripSeconds, TripMiles, PickupCensus, DropOffCensus,
			PickupComArea, DropOffComArea, Fare, Tips, Tolls, ExtraCharges, TripTotal, PaymentType,
			TaxiCompany, PickupCentroidLatitude, PickupCentroidLongitude, PickupCentroidLocation,
			DropOffCentroidLatitude, DropOffCentroidLongitude, DropOffCentroidLocation)
		ON r.TripId = v.Tripid AND r.TripStart = v.TripStart
		WHEN matched THEN
			UPDATE SET TaxiId = v.TaxiId, 
				TripEnd = v.TripEnd, 
				TripSeconds = v.TripSeconds, 
				TripMiles = v.TripMiles, 
				PickupCensus = v.PickupCensus, 
				DropOffCensus = v.DropOffCensus,
				PickupComArea = v.PickupComArea, 
				DropOffComArea = v.DropOffComArea, 
				Fare = v.Fare, 
				Tips = v.Tips, 
				Tolls = v.Tolls, 
				ExtraCharges = v.ExtraCharges, 
				TripTotal = v.TripTotal, 
				PaymentType = v.PaymentType,
				TaxiCompany = v.TaxiCompany, 
				PickupCentroidLatitude = v.PickupCentroidLatitude, 
				PickupCentroidLongitude = v.PickupCentroidLongitude, 
				PickupCentroidLocation = v.PickupCentroidLocation,
				DropOffCentroidLatitude = v.DropOffCentroidLatitude, 
				DropOffCentroidLongitude = v.DropOffCentroidLongitude, 
				DropOffCentroidLocation = v.DropOffCentroidLocation,
				rec_updated = current_timestamp			
		WHEN NOT matched THEN
			INSERT (TripId, TaxiId, TripStart, TripEnd, TripSeconds, TripMiles, PickupCensus, DropOffCensus,
			PickupComArea, DropOffComArea, Fare, Tips, Tolls, ExtraCharges, TripTotal, PaymentType,
			TaxiCompany, PickupCentroidLatitude, PickupCentroidLongitude, PickupCentroidLocation,
			DropOffCentroidLatitude, DropOffCentroidLongitude, DropOffCentroidLocation, rec_updated)
			VALUES (v.TripId, v.TaxiId, v.TripStart, v.TripEnd, v.TripSeconds, v.TripMiles, v.PickupCensus, v.DropOffCensus,
			v.PickupComArea, v.DropOffComArea, v.Fare, v.Tips, v.Tolls, v.ExtraCharges, v.TripTotal, v.PaymentType,
			v.TaxiCompany, v.PickupCentroidLatitude, v.PickupCentroidLongitude, v.PickupCentroidLocation,
			v.DropOffCentroidLatitude, v.DropOffCentroidLongitude, v.DropOffCentroidLocation, current_timestamp)";

		}
	}
}
