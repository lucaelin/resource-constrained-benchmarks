using System;
using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc;
using apples.Data;
using apples.Models;

namespace apples.Controllers
{
    [ApiController]
    [Route("{uuid}")]
    public class ApplesController : ControllerBase
    {
        private readonly IEventRepository _eventRepository;

        public ApplesController(IEventRepository eventRepository)
        {
            _eventRepository = eventRepository;
        }

        [HttpPost("command")]
        public Event HandleCommand(Guid uuid, [FromBody] Command command)
        {
            List<Event> events = _eventRepository.FindByAggregateUuid(uuid);

            Aggregate aggregate = new Aggregate(uuid);
            events.ForEach(aggregate.Apply);

            Event evt = new Event(uuid) { Data = command.Data };

            aggregate.Apply(evt);

            return _eventRepository.Save(evt);
        }

        [HttpGet("query")]
        public string HandleQuery(Guid uuid)
        {
            List<Event> events = _eventRepository.FindByAggregateUuid(uuid);

            Projection projection = new Projection();
            events.ForEach(projection.Apply);

            return projection.GetState();
        }
    }
}
