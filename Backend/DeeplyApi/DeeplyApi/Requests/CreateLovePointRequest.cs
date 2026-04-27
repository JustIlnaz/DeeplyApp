namespace DeeplyApi.Requests;

public class CreateLovePointRequest
{
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public string? PhotoUrl { get; set; }
    public string? Description { get; set; }
}
