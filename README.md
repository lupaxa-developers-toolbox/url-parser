<p align="center">
  <a href="https://github.com/lupaxa-developers-toolbox">
    <img src="https://raw.githubusercontent.com/the-lupaxa-project/brand-assets/master/logos/organisations/developers-toolbox/readme-logo.png" alt="Developers Toolbox" />
  </a>
</p>

<h1 align="center">URL Parser</h1>

Sourceable Bash helper that splits a URL into protocol, user, password, host, port, path, query, and fragment.

## Requirements

- Bash 3.2 or later

## Use

```bash
source src/url-parser.sh
parse_url 'https://github.com/example/tools.git'
echo "${URL_HOST}"
echo "${URL_PATH}"
```

Run [demo.sh](demo.sh) to print a set of sample URLs.

## Results

`parse_url` writes these variables. Each call clears them first.

| Name           | Description                                                                 |
| :------------- | :-------------------------------------------------------------------------- |
| `URL`          | The input string.                                                           |
| `URL_PROTOCOL` | Scheme, lowercased, without `://`. Empty when there is none.                |
| `URL_USER`     | User info before the first `:`.                                             |
| `URL_PASS`     | Everything after the first `:` in the user info.                            |
| `URL_HOST`     | Host name. IPv6 addresses are stored without brackets.                      |
| `URL_PORT`     | Explicit port, or the default for a known scheme.                           |
| `URL_PATH`     | Path, including a leading `/` when the URL has one.                         |
| `URL_QUERY`    | Text after `?` and before `#`.                                              |
| `URL_FRAGMENT` | Text after `#`. A `?` inside the fragment stays there.                      |

When the URL has no port and the scheme is known, `URL_PORT` is filled from this table. An explicit port wins. An unknown scheme leaves the port empty.

| Scheme  | Port |
| :------ | :--- |
| `http`  | 80   |
| `https` | 443  |
| `ssh`   | 22   |
| `sftp`  | 22   |
| `ftp`   | 21   |
| `ftps`  | 990  |
| `git`   | 9418 |

Add a scheme by adding one arm to `default_port_for_scheme` in `src/url-parser.sh`.

`git@host:path` has no scheme. It is treated as SSH: port `22`, and the path is everything after the first `:`. `ssh://git@host/path` is a normal URL, so the path keeps its leading `/`.

Write an IPv6 host in brackets: `http://[::1]:8080/path` yields host `::1` and port `8080`. A zone id is written `%25`, so `http://[fe80::1%25eth0]/` yields host `fe80::1%eth0`.

User, password, host, path, query, and fragment are percent-decoded. `%20` becomes a space. A trailing incomplete sequence such as `%2`, and `%00`, are left as written.

## Subroutines

| Name                      | Purpose                                    |
| :------------------------ | :----------------------------------------- |
| `parse_url`               | Split one URL into the variables.          |
| `default_port_for_scheme` | Return the default port for a scheme name. |
| `get_version`             | Print the library version string.          |

## Development

```bash
make init
make check
```

`make init` checks out makefile-skills. `make check` runs ShellCheck, `bash -n`, and `tests/run_all.sh`.

<a href="https://github.com/the-lupaxa-project">
    <img src="https://raw.githubusercontent.com/the-lupaxa-project/brand-assets/master/logos/components/footer-for-child-orgs.svg" alt="The Lupaxa Project Footer" width="100%" />
</a>
