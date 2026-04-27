namespace DeeplyApi.Requests;

public class CreateMoodRequest
{
    public string MoodType { get; set; } = string.Empty;
    public string? Comment { get; set; }
}
