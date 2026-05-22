using Microsoft.EntityFrameworkCore;
using Sefapi.Models;

namespace Sefapi.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<Berles> Berlesek { get; set; }
    }
}
