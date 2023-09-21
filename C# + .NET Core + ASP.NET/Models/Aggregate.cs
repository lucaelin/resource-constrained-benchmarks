using System;
using System.Text;

namespace apples.Models
{
    public class Aggregate
    {
        public Guid AggregateUuid { get; set; }
        private StringBuilder State { get; } = new StringBuilder();

        public Aggregate(Guid aggregateUuid)
        {
            AggregateUuid = aggregateUuid;
        }

        public void Apply(Event evt)
        {
            State.Append(evt.Data);
        }

        public string GetState()
        {
            return State.ToString();
        }
    }
}
