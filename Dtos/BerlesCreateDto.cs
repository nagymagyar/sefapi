using System;

namespace Sefapi.Dtos
{
    public class BerlesCreateDto
    {
        public int Uid { get; set; }
        public int ChefId { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public int DailyRate { get; set; }
        public int BaseFee { get; set; }
    }
}
