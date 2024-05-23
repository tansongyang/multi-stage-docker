# multi-stage-docker

This is a demo of some capabilities of [Multi-stage Docker builds](https://docs.docker.com/build/guide/multi-stage/).

The core of the demo is a simple Express server running on http://localhost/3000. Start it like this so that you can observe Docker's build process:

```sh
`docker compose up --build`
```

The commits tell the story of how this this demo app grew and what Docker features were used along the way. You can `git checkout` any of the various tagged commits and run `docker compose up --build` to see what difference each change set makes. There are also additional comments in [Dockerfile](./Dockerfile), [.dockerignore](./.dockerignore), and [compose.yml](./compose.yml).

To test your understanding, here are some questions:

1. After adding the `tests` stage, the `build` stage now runs when tests change. How can you make that not be the case?
1. What would be the pros and cons of moving tests into a nested package, like the server?