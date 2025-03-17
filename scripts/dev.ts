import "zx/globals";

const SERVICES = [
  "alpinelinux",
  "archlinux",
  "debian",
  "kalilinux",
  "ubuntu",
  "almalinux",
  "amazonlinux",
  "fedora",
  "rockylinux",
] as const;

async function choiceContainer(
  container: string | undefined,
): Promise<(typeof SERVICES)[number]> {
  if (SERVICES.some((service) => service === container)) {
    return container as (typeof SERVICES)[number];
  }

  for (;;) {
    const container = await question(`Choice container [${SERVICES}] ❯ `);

    if (SERVICES.some((service) => service === container)) {
      return container as (typeof SERVICES)[number];
    }
  }
}

const container = await choiceContainer(argv._[0]);

const UID = await $`id --user`;
const GID = await $`id --group`;

await $`WORK_UID=${UID} WORK_GID=${GID} docker compose up ${container} --detach --build`;

await $`docker exec --interactive --tty dotfiles-${container} /bin/bash`;
