namespace DeeplyApi.Requests;

public class CreateMemoryRequest
{
    public string? Text { get; set; }
    public IFormFile? Photo { get; set; }
    public IFormFile? Video { get; set; }
    public bool IsPinned { get; set; }
}
