using Microsoft.EntityFrameworkCore;
using apples.Models;

namespace apples.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options)
            : base(options)
        { }

        public DbSet<Event> Events { get; set; }
    }
}
