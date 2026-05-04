using System.ComponentModel.DataAnnotations;

namespace DeeplyApi.Models;

public class Gender
{
    [Key] public int Id { get; set; }
    [MaxLength(100)] public string Name { get; set; } = string.Empty;
    
    public virtual ICollection<User> Users { get; set; } = [];
}
