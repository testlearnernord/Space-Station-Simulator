using System.IO;
using System.Threading.Tasks;
using Xunit;
using SimCore.Persistence;

namespace SimCore.Tests;

public class SaveLoadTests
{
    private record DummyState(int X, string Name);

    [Fact]
    public async Task Save_and_load_roundtrip()
    {
        var tmp = Path.GetTempFileName();
        var path = tmp + ".json.gz";
        var state = new DummyState(5, "hello");
        await SaveLoad.SaveGzipAsync(path, state);
        var loaded = await SaveLoad.LoadGzipAsync<DummyState>(path);
        Assert.Equal(state.X, loaded.X);
        Assert.Equal(state.Name, loaded.Name);
        File.Delete(path);
    }
}