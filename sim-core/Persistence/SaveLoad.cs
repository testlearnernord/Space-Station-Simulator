using System;
using System.IO;
using System.IO.Compression;
using System.Text.Json;
using System.Threading.Tasks;

namespace SimCore.Persistence;

public static class SaveLoad
{
    public static async Task SaveGzipAsync<T>(string path, T obj)
    {
        using var fs = File.Create(path);
        using var gz = new GZipStream(fs, CompressionLevel.Optimal);
        await JsonSerializer.SerializeAsync(gz, obj, new JsonSerializerOptions { WriteIndented = true });
    }

    public static async Task<T> LoadGzipAsync<T>(string path)
    {
        using var fs = File.OpenRead(path);
        using var gz = new GZipStream(fs, CompressionMode.Decompress);
        return await JsonSerializer.DeserializeAsync<T>(gz) ?? throw new InvalidOperationException("Deserialize returned null");
    }
}