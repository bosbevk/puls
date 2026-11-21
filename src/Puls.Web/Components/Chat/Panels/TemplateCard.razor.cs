using Puls.Web.Content;
using Microsoft.AspNetCore.Components;

namespace Puls.Web.Components.Chat.Panels;

public partial class TemplateCard
{
    [Parameter, EditorRequired] public Template Template { get; set; } = default!;
    [Parameter] public EventCallback<Template> OnStart { get; set; }
}
