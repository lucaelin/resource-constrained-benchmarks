using System.Text;
using apples.Models;

namespace apples.Models
{
    public class Projection
    {
        private StringBuilder State { get; } = new StringBuilder();

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
