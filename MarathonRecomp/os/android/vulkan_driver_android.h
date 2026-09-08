#pragma once

// Experiment: load a custom Vulkan ICD (Mesa Turnip) via libadrenotools instead of the vendor
// proprietary driver, to work around a driver-side shader compiler assertion seen with this
// engine's buffer_device_address-based bindless resource access on the stock Adreno blob.
//
// Returns a vkGetInstanceProcAddr function pointer (cast to PFN_vkGetInstanceProcAddr by the
// caller) if the custom driver at ANDROID_CUSTOM_VULKAN_DRIVER_PATH was found and loaded
// successfully, or nullptr if the file isn't present or loading failed - callers should fall
// back to the default driver loading path (volkInitialize()) in that case.
// extern "C" linkage so it can be forward-declared and called from within plume's "plume"
// namespace (plume_vulkan.cpp) without needing to match/qualify a C++ namespace across the
// MarathonRecomp <-> plume translation unit boundary.
extern "C" void *AndroidGetCustomVulkanLoader();

// Called by Video only after both the Vulkan device and a usable swapchain exist. This is
// deliberately separate from AndroidGetCustomVulkanLoader(): dlopen/vkGetInstanceProcAddr
// succeeding does not prove that the selected driver can finish Vulkan startup.
void AndroidMarkVulkanStartupSuccessful();

// Adreno model number detected from kgsl sysfs BEFORE any Vulkan driver was loaded (e.g.
// 610), or 0 when the kernel nodes were unreadable. Video uses it to cross-check that
// pre-load decision against the Vulkan device name, so a wrong guess shows up in the log
// instead of silently applying (or skipping) the low-end compatibility preset.
int AndroidGetDetectedAdrenoModel();
