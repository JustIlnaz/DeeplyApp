using System.ComponentModel.DataAnnotations;

namespace DeeplyApi.Models;

public class User
{
    [Key] public int Id { get; set; }
    [MaxLength(200)] public string Email { get; set; } = string.Empty;
    [MaxLength(200)] public string PasswordHash { get; set; } = string.Empty;
    [MaxLength(100)] public string Name { get; set; } = string.Empty;
    public int? GendreId { get; set; }
    public Gendre? Gendre { get; set; }
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
    public virtual ICollection<RefreshToken> RefreshTokens { get; set; } = [];
}
