using CsvHelper.Configuration.Attributes;
using TaxiCommon;

namespace TaxiLoad
{
	public class TaxiRideRec
	{
		// 1. Trip ID : A unique identifier for each trip, facilitating easy tracking and analysis.
		[Index(0)]
		public string TripId { get; set; } //0287f53fedcde6b0af9aab9e32cbd2cadb337eaa

		// 2. Taxi ID : An identifier for the taxi involved in each trip, enabling tracking of individual vehicles.
		[Index(1)]
		public string TaxiId { get; set; } // e54db25f18193a08f1f5754515e8c338480e04fb938ed3db5a0fccface463874280a3d496820aa02ac2c13c5238e2352f4c6cdfafbff3224043a64f366cbdaa4

		// 3. Trip Start Timestamp : When the trip started, rounded to the nearest 15 minutes.
		[Index(2)]
		public DateTime? TripStart { get; set; } // ,03/01/2024 12:00:00 AM

		// 4. Trip End Timestamp : When the trip ended, rounded to the nearest 15 minutes.
		// ,03/01/2024 12:00:00 AM
		[Index(3)]
		public DateTime? TripEnd { get; set; }

		// 5. Trip Seconds : Time of the trip in seconds.
		// ,15
		[Index(4)]
		public int? TripSeconds { get; set; }

		// 6. Trip Miles : Distance of the trip in miles.
		// ,0.09
		[Index(5)]
		public decimal? TripMiles { get; set; }

		// 7. Pickup Census Tract : The Census Tract where the trip began.For privacy, this Census Tract is not shown for some trips.This column often will be blank for locations outside Chicago.
		// ,
		[Index(6)]
		public string PickupCensus { get; set; }

		// 8. Dropoff Census Tract : The Census Tract where the trip ended.For privacy, this Census Tract is not shown for some trips. This column often will be blank for locations outside Chicago.
		// ,
		[Index(7)]
		public string DropOffCensus { get; set; }

		// 9. Pickup Community Area : The Community Area where the trip began.This column will be blank for locations outside Chicago.
		// ,8
		[Index(8)]
		public string PickupComArea { get; set; }

		// 10. Dropoff Community Area : The Community Area where the trip ended.This column will be blank for locations outside Chicago.
		// ,8
		[Index(9)]
		public string DropOffComArea { get; set; }

		// 11. Fare : The fare for the trip.
		// ,3.25
		[Index(10)]
		public decimal? Fare { get; set; }

		// 12. Tips : The tip for the trip. Cash tips generally will not be recorded.
		// ,0.00
		[Index(11)]
		public decimal? Tips { get; set; }

		// 13. Tolls : The tolls for the trip.
		// ,0.00
		[Index(12)]
		public decimal? Tolls { get; set; }

		// 14. Extras : Extra charges for the trip.
		// ,35.00
		[Index(13)]
		public decimal? ExtraCharges { get; set; }

		// 15. Trip Total: Total cost of the trip, the total of the previous columns.
		// ,38.75
		[Index(14)]
		public decimal? TripTotal { get; set; }

		// 16. Payment Type : Type of payment for the trip.
		// ,Credit Card
		[Index(15)]
		public string PaymentType { get; set; }

		// 17. Company : The taxi company.
		// , City Service
		[Index(16)]
		public string TaxiCompany { get; set; }

		// 18. Pickup Centroid Latitude : The latitude of the center of the pickup census tract or the community area if the census tract has been hidden for privacy.This column often will be blank for locations outside Chicago.
		// ,41.899602111
		[Index(17)]
		public string PickupCentroidLatitude { get; set; }

		// 19. Pickup Centroid Longitude : The longitude of the center of the pickup census tract or the community area if the census tract has been hidden for privacy.This column often will be blank for locations outside Chicago.
		// ,-87.633308037
		[Index(18)]
		public string PickupCentroidLongitude { get; set; }

		// 20. Pickup Centroid Location : The location of the center of the pickup census tract or the community area if the census tract has been hidden for privacy.This column often will be blank for locations outside Chicago.
		// ,POINT(-87.6333080367 41.899602111)
		[Index(19)]
		public string PickupCentroidLocation { get; set; }

		// 21. Dropoff Centroid Latitude : The latitude of the center of the dropoff census tract or the community area if the census tract has been hidden for privacy.This column often will be blank for locations outside Chicago.
		// ,41.899602111
		[Index(20)]
		public string DropOffCentroidLatitude { get; set; }

		// 22. Dropoff Centroid Longitude : The longitude of the center of the dropoff census tract or the community area if the census tract has been hidden for privacy.This column often will be blank for locations outside Chicago.
		// ,-87.633308037
		[Index(21)]
		public string DropOffCentroidLongitude { get; set; }

		// 23. Dropoff Centroid Location : The location of the center of the dropoff census tract or the community area if the census tract has been hidden for privacy.This column often will be blank for locations outside Chicago.
		// ,POINT(-87.6333080367 41.899602111)
		[Index(22)]
		public string DropOffCentroidLocation { get; set; }


		public string SqlValues()
		{
			return "(" +
				string.Join(',',
								ValueFormat(TripId),
								ValueFormat(TaxiId),
								ValueFormat(TripStart),
								ValueFormat(TripEnd),
								ValueFormat(TripSeconds),
								ValueFormat(TripMiles),
								ValueFormat(PickupCensus),
								ValueFormat(DropOffCensus),
								ValueFormat(PickupComArea),
								ValueFormat(DropOffComArea),
								ValueFormat(Fare),
								ValueFormat(Tips),
								ValueFormat(Tolls),
								ValueFormat(ExtraCharges),
								ValueFormat(TripTotal),
								ValueFormat(PaymentType),
								ValueFormat(TaxiCompany),
								ValueFormat(PickupCentroidLatitude),
								ValueFormat(PickupCentroidLongitude),
								ValueFormat(PickupCentroidLocation),
								ValueFormat(DropOffCentroidLatitude),
								ValueFormat(DropOffCentroidLongitude),
								ValueFormat(DropOffCentroidLocation)
								)
				+ ")";
		}

		public static string ValueFormat(string val)
		{
			if (val == null)
				return "NULL";

			if (string.IsNullOrWhiteSpace(val))
				return "NULL";

			return $"'{val}'";
		}
		public static string ValueFormat(DateTime? val)
		{
			if (!val.HasValue)
				return "NULL::TIMESTAMP";

			//TO_TIMESTAMP ('2024-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS')
			return $"TO_TIMESTAMP('{val.Value.ToString("yyyy-MM-dd HH:mm:ss")}','YYYY-MM-DD HH24:MI:SS')";
		}

		public static string ValueFormat(int? val)
		{
			if (!val.HasValue)
				return "NULL::INT";

			return val.ToString();
		}

		public static string ValueFormat(decimal? val)
		{
			if (!val.HasValue)
				return "NULL::DECIMAL";

			return val.Value.ToString(); // Displays -16325.62
		}

		public string GetYearWeek(TaxiRideRec record)
		{
			var weekOfYearStr = "WeekNull";
			if (record.TripStart.HasValue)
			{
				var weekOfYear = Consts.calendar.GetWeekOfYear(record.TripStart.Value, Consts.weekRule, Consts.firstDayOfWeek);
				weekOfYearStr = $"{record.TripStart.Value.Year}_{weekOfYear}";
			}

			return weekOfYearStr;
		}
	}
}
