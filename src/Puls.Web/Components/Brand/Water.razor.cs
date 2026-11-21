using Microsoft.AspNetCore.Components;

namespace Puls.Web.Components.Brand;

public partial class Water
{
    private readonly string _id = "water-" + Guid.NewGuid().ToString("N")[..8] + "-";
}
