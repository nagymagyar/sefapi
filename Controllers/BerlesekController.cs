using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Sefapi.Data;
using Sefapi.Dtos;
using Sefapi.Models;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Sefapi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class BerlesekController : ControllerBase
    {
        private readonly AppDbContext _db;

        public BerlesekController(AppDbContext db)
        {
            _db = db;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<Berles>>> GetAll()
        {
            var list = await _db.Berlesek.ToListAsync();
            return Ok(list);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<Berles>> GetById(int id)
        {
            var b = await _db.Berlesek.FindAsync(id);
            if (b == null) return NotFound();
            return Ok(b);
        }

        [HttpPost]
        public async Task<ActionResult<Berles>> Create(BerlesCreateDto dto)
        {
            var start = dto.StartDate.Date;
            var end = dto.EndDate.Date;
            var tomorrow = System.DateTime.Today.AddDays(1);

            if (start < tomorrow)
                return BadRequest("A bérlés kezdőnapja nem lehet korábbi, mint a holnapi nap.");

            var days = (end - start).Days + 1;
            if (days < 3)
                return BadRequest("A bérlés időtartama legalább 3 nap legyen.");
            if (days > 14)
                return BadRequest("A bérlés időtartama legfeljebb 14 nap lehet.");

            var overlap = await _db.Berlesek.AnyAsync(b => b.ChefId == dto.ChefId && !(b.EndDate.Date < start || b.StartDate.Date > end));
            if (overlap)
                return BadRequest("A séf a megadott időszakban már foglalt.");

            var entity = new Berles
            {
                Uid = dto.Uid,
                ChefId = dto.ChefId,
                StartDate = start,
                EndDate = end,
                DailyRate = dto.DailyRate,
                BaseFee = dto.BaseFee
            };

            _db.Berlesek.Add(entity);
            await _db.SaveChangesAsync();

            return CreatedAtAction(nameof(GetById), new { id = entity.Id }, entity);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var b = await _db.Berlesek.FindAsync(id);
            if (b == null) return NotFound();
            _db.Berlesek.Remove(b);
            await _db.SaveChangesAsync();
            return NoContent();
        }
    }
}
