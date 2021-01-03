# NAME

Dist::Zilla::Plugin::GitHub::RequireGreenBuild - Require a successful GitHub Actions workflow run

# SYNOPSIS

```
# in your dist.ini:
[GitHub::RequireGreenBuild]
```

# DESCRIPTION

This `Dist::Zilla` plugin checks your GitHub Actions for a successful run,
before allowing a release.

e.g. until we can determine that you have a green build for a GitHub Actions run
against `HEAD`, you're not allowed to release.

# AUTHOR

Graham TerMarsch (cpan@howlingfrog.com)

# COPYRIGHT

Copyright (C) 2021-, Graham TerMarsch.  All Rights Reserved.

This is free software; you can redistribute it and/or modify it under the same
license as Perl itself.

# SEE ALSO

- [Dist::Zilla](https://metacpan.org/pod/Dist%3A%3AZilla)
- [Dist::Zilla::Plugin::GitHub](https://metacpan.org/pod/Dist%3A%3AZilla%3A%3APlugin%3A%3AGitHub)
