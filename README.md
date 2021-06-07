# DependencyBuilder
Builds dependencies for your C++ application on Linux and Windows

# Motivation
When looking at deploying a C++ application that can be ran in several environments, one has to consider that companies (and people) operate in a variety of environments.

For a commercial C++ application be deployed, it needs at minimum a collection of common libraries (dependencies) and an up-to-date set of building tools. However the variety of environments - machines and operating systems - is so distinct from each other that one has no choice other than building all libraries by themselves. 

Of course, there are many package builders out there: 

1. The distributions themselves (Ubuntu, Redhat, Debian, Suse, Gentoo, ArchLinux)
2. Integrated build systems (Conan, Pkgsrc, vcpkg, etc)

Every one of these above have done their work to create binaries. However we wanted something with unique characteristics:

1. Bash only. No Ruby, Python or any custom languages
2. Be easy to maintain
3. Have basic functionality (download, compile) but still provide an easy mechanism for overriding with a completely manual process
4. Maintain a cache of tarballs so not to overwhelm the internet connection
5. Build everything in a single batch, not interactively
6. Produce an installation folder that can be zipped and included in your commercial application then shipped to a client

# Supported Architectures
For version 1.0 we intend to provide support for the major commercial distributions, Redhat and Ubuntu on Linux and Windows 10. 
For now we are supporting Intel x86_64 but that can change in the future as other platforms are certified.

# TODO
1. Update the MSYS/Windows folder
2. Setup some sort of automated build with docker in aws (EKS or Amazon Batch)
3. Review and clean up the current code
