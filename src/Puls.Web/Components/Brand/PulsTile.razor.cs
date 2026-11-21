using Microsoft.AspNetCore.Components;

namespace Puls.Web.Components.Brand;

public partial class PulsTile
{
    private readonly string _id = "tile-" + Guid.NewGuid().ToString("N")[..8] + "-";
}
