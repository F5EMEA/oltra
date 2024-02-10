# Gitlab-Runner

## update gitlab-runner

Update

1. Create Runner: After registering the runner, you can start it with the following command:

```
docker run -d --name gitlab-runner --restart always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /etc/gitlab-runner:/etc/gitlab-runner \
  gitlab/gitlab-runner:v16.7.0
```

2. Verify Runner: Once the runner is running, you can verify its status by running:

```
docker exec -it gitlab-runner gitlab-runner verify
```
> This command should show you that the runner is registered and able to connect to your GitLab instance.

3. Configure GitLab Pipeline: Finally, you need to configure your GitLab project to use the runner. This involves adding a .gitlab-ci.yml file to your project's repository with the desired CI/CD pipeline configuration.

## Installation (already done)

Here's a basic outline of how you can set it up:


1. Pull GitLab Runner Docker Image: You'll need to pull the GitLab Runner Docker image from the Docker Hub. You can do this using the following command:

```bash
docker pull gitlab/gitlab-runner:v16.7.0
```
Register Runner: Once you have the GitLab Runner Docker image, you need to register the runner with your GitLab instance. You can do this by running the following command:

```bash
docker run -dit --rm -v /etc/gitlab-runner:/etc/gitlab-runner gitlab/gitlab-runner:v16.7.0
docker exec -it 'name' /bin/bash
gitlab-runner register
... follow the instrustions..
```
> Follow the prompts to configure the runner. You'll need your GitLab instance URL and a registration token, which you can obtain from your GitLab project's settings.


4. Start Runner: After registering the runner, you can start it with the following command:

```
docker run -d --name gitlab-runner --restart always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /etc/gitlab-runner:/etc/gitlab-runner \
  gitlab/gitlab-runner:v16.7.0
```

> Replace /path/to/config with the directory where you stored the runner's configuration.

4. Verify Runner: Once the runner is running, you can verify its status by running:


```
docker exec -it gitlab-runner gitlab-runner verify
```
> This command should show you that the runner is registered and able to connect to your GitLab instance.


5. Configure GitLab Pipeline: Finally, you need to configure your GitLab project to use the runner. This involves adding a .gitlab-ci.yml file to your project's repository with the desired CI/CD pipeline configuration.
