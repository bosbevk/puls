using Puls.Web.Content;
using Microsoft.AspNetCore.Components;

namespace Puls.Web.Components.Chat.Panels;

public partial class ExploreView
{
    [Parameter] public EventCallback<Template> OnStart { get; set; }

    private static string Anchor(string section) => section.ToLowerInvariant();
}
