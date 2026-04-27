namespace DeeplyApi.Requests;

public class CreateMemoryRequest
{
    public string? Text { get; set; }
    public string? PhotoUrl { get; set; }
    public string? VideoUrl { get; set; }
    public bool IsPinned { get; set; }
}
