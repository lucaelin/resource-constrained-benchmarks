using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace apples.Models
{
    public class Event
    {
        [Key]
        public long Id { get; set; }
        
        public Guid AggregateUuid { get; set; }

        public string Data { get; set; }

        public Event() { }

        public Event(Guid aggregateUuid)
        {
            AggregateUuid = aggregateUuid;
        }
    }
}
