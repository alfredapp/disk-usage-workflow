import Foundation

// Helpers
struct ScriptFilterItem: Codable {
  let title: String
  let subtitle: String
  let icon: [String: String]
  let arg: String
}

// Grab root and ejectable volumes
guard
  let disks = FileManager.default.mountedVolumeURLs(
    includingResourceValuesForKeys: nil, options: .skipHiddenVolumes)
else { fatalError("Unable to get disk information") }

// Make items
let sfItems: [ScriptFilterItem] = disks.map { disk in
  guard
    let resourceValues = try? disk.resourceValues(forKeys: [
      .volumeTotalCapacityKey, .volumeAvailableCapacityKey, .volumeLocalizedNameKey,
    ]),
    let totalCapacity = resourceValues.volumeTotalCapacity,
    let availableCapacity = resourceValues.volumeAvailableCapacity,
    let volumeName = resourceValues.volumeLocalizedName
  else { fatalError("bla") }

  let usedCapacity = totalCapacity - availableCapacity
  let freePercentage = availableCapacity * 100 / totalCapacity

  let totalCapacityString = ByteCountFormatter.string(
    fromByteCount: Int64(totalCapacity), countStyle: .file)
  let availableCapacityString = ByteCountFormatter.string(
    fromByteCount: Int64(availableCapacity), countStyle: .file)
  let usedCapacityString = ByteCountFormatter.string(
    fromByteCount: Int64(usedCapacity), countStyle: .file)

  return ScriptFilterItem(
    title: "\(volumeName): \(availableCapacityString) free",
    subtitle: "\(freePercentage)% free · \(usedCapacityString) used of \(totalCapacityString)",
    icon: ["path": disk.path, "type": "fileicon"],
    arg: disk.path
  )
}

// Output JSON
let jsonData = try JSONEncoder().encode(["items": sfItems])
print(String(data: jsonData, encoding: .utf8)!)
