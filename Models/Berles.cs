using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Sefapi.Models
{
    public class Berles
    {
        [Key]
        public int Id { get; set; }
        public int Uid { get; set; }
        public int ChefId { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public int DailyRate { get; set; }
        public int BaseFee { get; set; }

        [NotMapped]
        public int TotalPrice
        {
            get
            {
                var days = (EndDate.Date - StartDate.Date).Days + 1;
                if (days < 0) days = 0;
                return BaseFee + DailyRate * days;
            }
        }
    }
}
