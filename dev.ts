import "zx/globals";

const containers = argv._;

const services = [
  "archlinux",
  "debian",
  "ubuntu",
  "almalinux",
  "amazonlinux",
  "fedora",
  "rockylinux",
  "opensuse",
];

if (
  !containers.length ||
  !containers.some((container) =>
    services.some((service) => service === container),
  )
) {
  containers.length = 0;

  for (;;) {
    const container = await question(`Choice container [${services}] ❯ `, {
      choices: services,
    });

    if (services.some((service) => service === container)) {
      containers.push(container);
      break;
    }
  }
}

const UID = await $`id --user`;
const GID = await $`id --group`;

await $`WORK_UID=${UID} WORK_GID=${GID} docker compose up ${containers} -d --build`;
