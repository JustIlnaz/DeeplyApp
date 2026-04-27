using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DeeplyApi.Models;

public class Couple
{
    [Key] public int Id { get; set; }
    [ForeignKey(nameof(User1))] public int User1Id { get; set; }
    [ForeignKey(nameof(User2))] public int? User2Id { get; set; }
    [MaxLength(32)] public string InviteCode { get; set; } = string.Empty;
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
    public DateOnly? AnniversaryDate { get; set; }
    public virtual User? User1 { get; set; }
    public virtual User? User2 { get; set; }
}
