using System.Globalization;

namespace TaxiCommon
{
	public static class Consts
	{
		public static readonly string BaseDir = @"C:\temp\Taxi";
		public static readonly string RawFullFile = Path.Join(BaseDir, @"RawData\Full\Taxi_Trips_-_2024_20240408.csv");
		public static readonly string WeeklyDir = Path.Join(BaseDir, @"RawData\Weekly");

		public static readonly Calendar calendar = CultureInfo.InvariantCulture.Calendar;
		public static readonly CalendarWeekRule weekRule = CalendarWeekRule.FirstDay;
		public static readonly DayOfWeek firstDayOfWeek = DayOfWeek.Monday;
	}
}
