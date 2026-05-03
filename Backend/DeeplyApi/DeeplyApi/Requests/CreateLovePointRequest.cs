namespace DeeplyApi.Requests;

public class CreateLovePointRequest
{
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public IFormFile? Photo { get; set; }
    public string? Description { get; set; }
    public string? Address { get; set; }
}
