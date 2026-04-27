using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DeeplyApi.Models;

public class FinanceGoal
{
    [Key] public int Id { get; set; }
    public int CoupleId { get; set; }
    [MaxLength(200)] public string Title { get; set; } = string.Empty;
    [Column(TypeName = "numeric(18,2)")] public decimal TargetAmount { get; set; }
    [Column(TypeName = "numeric(18,2)")] public decimal CurrentAmount { get; set; }
}
