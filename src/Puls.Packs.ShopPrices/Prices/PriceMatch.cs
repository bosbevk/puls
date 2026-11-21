using Puls.Packs.ShopPrices.Prices.Files;
namespace Puls.Packs.ShopPrices.Prices;

/// <summary>The product a shopping-list line was matched to, and the table it is from (Stats SA's, or ours).</summary>
public sealed record PriceMatch(PriceProduct Product, PriceFile File);
