#:package AsmResolver.DotNet@6.*-*

using System.Collections.Concurrent;
using AsmResolver.DotNet;
using AsmResolver.PE.DotNet.Metadata.Tables;

if (args.Length < 1)
{
    Console.Error.WriteLine("Usage: dotnet run Publicize.cs -- <managed-dir>");
    return 1;
}

var dir = args[0];
var targets = Directory.EnumerateFiles(dir, "*.dll")
    .Where(p => ShouldPublicize(Path.GetFileNameWithoutExtension(p)))
    .ToArray();

var failures = new ConcurrentBag<string>();
var totalTypes = 0;
var totalMethods = 0;
var totalFields = 0;

Parallel.ForEach(targets, path =>
{
    try
    {
        var (types, methods, fields) = Publicize(path);

        Interlocked.Add(ref totalTypes, types);
        Interlocked.Add(ref totalMethods, methods);
        Interlocked.Add(ref totalFields, fields);

        Console.WriteLine($"Publicized {Path.GetFileName(path)}: {types} types, {methods} methods, {fields} fields");
    }
    catch (Exception ex)
    {
        failures.Add(Path.GetFileName(path));
        Console.Error.WriteLine($"failed {Path.GetFileName(path)}: {ex.Message}");
    }
});

Console.WriteLine();
Console.WriteLine(
    $"total: " +
    $"{targets.Length - failures.Count}/{targets.Length} assemblies, " +
    $"{totalTypes} types, " +
    $"{totalMethods} methods, " +
    $"{totalFields} fields"
);

if (!failures.IsEmpty)
{
    Console.Error.WriteLine($"Failed: {string.Join(", ", failures)}");
}

return failures.IsEmpty ? 0 : 1;

static (int types, int methods, int fields) Publicize(string path)
{
    var module = ModuleDefinition.FromBytes(File.ReadAllBytes(path));
    var typeCount = 0;
    var methodCount = 0;
    var fieldCount = 0;

    foreach (var type in module.GetAllTypes())
    {
        typeCount++;
        type.Attributes = (type.Attributes & ~TypeAttributes.VisibilityMask)
                          |
                          (type.IsNested ? TypeAttributes.NestedPublic : TypeAttributes.Public);

        foreach (var method in type.Methods)
        {
            methodCount++;
            method.Attributes = (method.Attributes & ~MethodAttributes.MemberAccessMask) | MethodAttributes.Public;
        }

        foreach (var field in type.Fields)
        {
            fieldCount++;
            field.Attributes = (field.Attributes & ~FieldAttributes.FieldAccessMask) | FieldAttributes.Public;
        }
    }

    module.Write(path);
    return (typeCount, methodCount, fieldCount);
}

static bool ShouldPublicize(string name)
{
    return name.StartsWith("Assembly-CSharp", StringComparison.Ordinal)
           || name.StartsWith("Facepunch.", StringComparison.Ordinal)
           || name.StartsWith("Rust.", StringComparison.Ordinal);
}