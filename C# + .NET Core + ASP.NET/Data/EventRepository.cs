using System;
using System.Collections.Generic;
using apples.Models;
using System.Linq;
using Microsoft.EntityFrameworkCore;

namespace apples.Data
{
    public interface IEventRepository
    {
        List<Event> FindByAggregateUuid(Guid uuid);
        Event Save(Event evt);
    }
    
    public class EventRepository : IEventRepository
    {
        private readonly AppDbContext _context;

        public EventRepository(AppDbContext context)
        {
            _context = context;
        }

        public List<Event> FindByAggregateUuid(Guid uuid)
        {
            return _context.Events
                .Where(e => e.AggregateUuid == uuid)
                .ToList();
        }

        public Event Save(Event evt)
        {
            _context.Events.Add(evt);
            _context.SaveChanges();
            return evt;
        }
    }
}
