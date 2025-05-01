using CsvHelper;
using CsvHelper.Configuration;
using System.Globalization;
using TaxiCommon;

namespace TaxiLoad
{
	internal class TaxiSplitMain
	{
		public static readonly int MaxCacheSize = 50000;
		public static readonly Dictionary<string, List<TaxiRideRec>> RecordCache = [];

		// 865248 rows total should be, with header
		public static int RowsRead = 0;
		public static int RowsWritten = 0;

		public static void Main(string[] args)
		{
			ClearWeeklyDir();

			ProcessFullRaw();
		}


		public static void ProcessFullRaw()
		{
			Console.WriteLine($"Reading: {Consts.RawFullFile}");

			using (var fileStream = File.OpenRead(Consts.RawFullFile))
			using (BufferedStream bufRead = new BufferedStream(fileStream, 5 * 1048576))
			using (var strmRead = new StreamReader(bufRead))
			using (var csv = new CsvReader(strmRead, CultureInfo.InvariantCulture))
			{
				// Read the header row
				csv.Read();
				csv.ReadHeader();
				var headerNames = csv.HeaderRecord;
				if (headerNames != null && headerNames.Length > 0)
					Console.WriteLine("Headers: " + string.Join(", ", headerNames));
				else
					Console.WriteLine("Headers missing");

				// Process all rows in raw dump
				while (csv.Read())
				{
					RowsRead++;
					var record = csv.GetRecord<TaxiRideRec>();

					var woy = record.GetYearWeek(record);

					if (RecordCache.TryGetValue(woy, out var recLst))
						recLst.Add(record);
					else
						RecordCache[woy] = new List<TaxiRideRec>(MaxCacheSize) { record };

					if (RowsRead % 10000 == 0)
					{
						Console.WriteLine($"Row {RowsRead}. Flushing");
						FlushCache();
					}

				}
			}

			Console.WriteLine($"Rows read total: {RowsRead}. Flushing");
			FlushCache();

			Console.WriteLine($"Rows written total: {RowsWritten}");
		}

		private static void ClearWeeklyDir()
		{
			string[] csvFiles = Directory.GetFiles(Consts.WeeklyDir, "*.csv");
			foreach (string file in csvFiles)
			{
				Console.WriteLine($"Deleting: {file}");
				File.Delete(file);
			}
		}

		private static void FlushCache()
		{
			foreach (var kv in RecordCache)
			{
				var weekOfYearFileName = $"{kv.Key}.csv";
				var woyPath = Path.Join(Consts.WeeklyDir, weekOfYearFileName);

				var recLst = kv.Value;

				Console.WriteLine($"Saving {recLst.Count} to {weekOfYearFileName}");

				var config = new CsvConfiguration(CultureInfo.InvariantCulture)
				{
					HasHeaderRecord = false // Set to false to skip writing the header
				};

				using (StreamWriter writer = new StreamWriter(woyPath, append: true))
				using (var csv = new CsvWriter(writer, config))
				{
					csv.WriteRecords(recLst);
					RowsWritten += recLst.Count;
				}
			}

			RecordCache.Clear();
		}

	}
}
