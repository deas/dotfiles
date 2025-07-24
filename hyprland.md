# Introduction to Hyprland

Hyprland is a dynamic tiling Wayland compositor that stands out for its fluid animations, extensive customization options, and focus on providing a visually appealing desktop experience. It is written in C++ and emphasizes speed and responsiveness.

## Features

Hyprland offers a rich set of features, including:

- **Dynamic Tiling:** Automatically arranges windows in a tiling layout, but also allows for floating windows.
- **Eye Candy:** Provides various visual enhancements such as rounded corners, blur effects, complex animations, and gradient borders.
- **Extensive Customization:** Configuration is handled through a human-readable text file, allowing for deep customization of the look and feel.
- **Plugin Support:** Functionality can be extended with a powerful plugin system.
- **Wayland Native:** Built from the ground up for Wayland, it supports modern features like screen sharing and touchpad gestures.
- **Active Development:** The project is under continuous development with a vibrant community.

## Technical Implementation

Hyprland is built on top of `wlroots`, a modular Wayland compositor library. It is primarily written in C++, which contributes to its performance. The rendering is handled by OpenGL ES, which allows for the complex animations and graphical effects that Hyprland is known for. Its configuration system is designed to be simple and instantly reloadable, making it easy for users to tweak their environment on the fly.

## Documentation

This folder [hyprland-wiki](./hyprland-wiki) contains the Hyprland documentation sources. It is based on markdown. The Hugo static site generator can be used to generate the website.

### Structure

The folder [hyprland-wiki/content](./hyprland-wiki/content) contains the root folder which as hierarchical folder structure. The root page is [hyprland-wiki/content/\_index.md](./hyprland-wiki/content/_index.md). Every folder has a similar main `_index.md` page. Folders and markdown files have very meaningful names, so you can easily find the content you are looking for.
