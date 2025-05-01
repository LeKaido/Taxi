namespace TaxiLoad
{
	public class TaxiFileLoadRec
	{
		public long FileId { get; set; }
		public string FileName { get; set; }
		public long FileSize { get; set; }
		public DateTime FileTime { get; set; }
		public DateTime LoadStart { get; set; }
		public DateTime? LoadEnd { get; set; }
		public long RowsRead { get; set; }
	}
}
