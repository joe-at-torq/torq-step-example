# **Description**

---

This article will guide you through the process of creating a custom container to use inside Torq as a step. This guide assumes that you have some knowledge of docker containers and also using docker hub.

# **Details**

---

Each custom container consists of two main components. The DockerFile and the entrypoint script. The DockerFile is used to define how the container is built inside the docker environment. This includes adding additional utilities or libraries into the container to use during execution.

The entry point script is used to gather the environment variables passed to the container and to execute the function of the step. The entry point can also be used to normalize the output data to JSON depending on the function of the step.

# DockerFile

You want to start with the DockerFile and the image you want to use in the step. You want to keep the size of the container as small as possible to cut down on execution time and complexity. [Alpine linux](https://hub.docker.com/_/alpine) is a good place to start as the size is around 5MB and fairly simple to use. Below is our example from the [torq-step-example](https://github.com/joe-at-torq/torq-step-example/blob/main/Dockerfile) GitHub repo. In this example we define the “alpine:latest” image to use along with our entrypoint.sh file and installation of the curl utility using apk.

```docker
FROM alpine:latest
COPY entrypoint.sh /entrypoint.sh
RUN  apk update \
   && apk add curl \
   && chmod +x entrypoint.sh
ENTRYPOINT ["/bin/ash","entrypoint.sh"]
```

# Entrypoint Script

The entry point controls the input, output, and also the signaling of the step when inside Torq. In the example we are using a simple bash script, however this can be in other formats if needed.

The first thing we do is check if the input parameter was provided to the step. Each input parameter defined will be presented to the container as an environment variable. This variable needs to be read by the entrypoint script and used where needed. In the example below the input parameter is “COMMAND”.

You will want to output JSON formatted text when exiting the step so that it integrates easier into the Torq ecosystem. In some cases it may be necessary to convert the output of some tools inside the container from one format to JSON. This can be done using jq or a number of other utilities depending on the original data format.

Script signaling is also an important part of the entrypoint script. Not all functions inside the container will provide proper console signaling or exit flags. In the case of a successful execution of your function, place and “exit 0” in the script. This will signal back to the Torq ecosystem that the step executed successfully and will provide a green checkmark to indicate the step execution was successful. If your function did not provide the expected output, add an “exit 9” to the script to signal an execution failure.

*Note the name of the input parameter in the Torq UI is the same as the $COMMAND variable name.*

https://lh4.googleusercontent.com/Hw1ao9N-PgfhpjZsTmFlUrEW3qu8fH8_SX1a5keua7jn2FM8_KcjqPgvKHF3SchnjUcy9nZCgkaH0Gjpx_meJCbEfv8NvE8M6VFtnlfABZ2EgTIqtteMTRUOsgCbLfqhhxLGHMZG_oS9GvEcw-2jVYI

```bash
if [ -z "$COMMAND" ] #Check if the required parameter is passed.
then
    echo "{\"error\":\"no command provided\"}"
    exit 9
else    
    echo "{\"command\":\"your command is $COMMAND\"}"
    exit 0
fi
```

---

# Building and testing your container

Once you have your DockerFile and entrypoint scripts created in the same directory, you are ready to test. Use “docker build” to start the build of your container. This can be done locally on your workstation with docker desktop installed or on a server instance with docker installed.

Below is an example of the command to execute. All steps for Torq will need the –platform set to “linux/amd64”. This can change depending on the OS you are using to build the image from.

```bash
docker build -t example . --platform=linux/amd64
```

---

After the build is complete you can execute a test run of the container and emulate how Torq would pass data to the container upon execution. For each parameter you have in your step, use the “--env” command to tell docker to pass an environment variable to the container. In our example, we only have one parameter called, “COMMAND”.

 

```bash
docker run -it --rm --name example --env COMMAND="such command, much wow!"
```

---

If the test is successful, the container will produce JSON formatted data.

```json
{"output": "Hello There. Your command is, such command, much wow!.\n"}
```

---

After building and testing locally, it is time to upload to [docker hub](http://hub.docker.com/) so that Torq can use the container inside of the UI. Each step has a version associated with it. This version is directly related to the tag version assigned to the docker image. Be sure this version is incremented each time a change is made to the container.

```bash
docker tag example yourdockerhub/example:1.0.0
docker push yourdockerhub/example:1.0.0
```

---

# Step YAML

Each step and workflow inside of Torq is formatted in YAML. The fields we need to adjust are the “name” and “env”. Start by dragging a new “Send HTTP request” step to the canvas. First rename the step then edit the YAML by selecting “Edit YAML” in the step menu  (three dots at the top right) and remove the “manifestId” line.

https://lh4.googleusercontent.com/WKmJMc6EsXUz5znIw_Jq1XBaWofiED6zHACb4MfGZuFfTaAz7jdAYZcg4a1J63pkkpE79X77xkAoVlUyT3t0yUOChaqpeEn-f_VbUmRV4wv1gPa78r6AO_rh7yggRdrtrbN0ClFwrexEDBd-8sOSwE8

```yaml
manifestId: c8beae5b-78e4-4401-b6b8-7cbfb534b88a
name: us-docker.pkg.dev/stackpulse/public/http/request:4.2.3
id: send_an_http_request
isPrivate: false
icon: ""
env:
 URL: ""
 METHOD: GET
 AUTHORIZATION: None
 HEADERS: ""
pretty_name: Send an HTTP request

```

---

The “name” field is the location of our container. In this example we have a docker hub repo named, “helloworld” with a tag version of, “1.0.0”  inside the “joeattorq” docker hub account.

The “env” field is a list (note the indention) of the input parameters we want to pass to the container when executed. Each key name, “COMMAND” in this example, is the name of the environment variable the container needs to pull data from. Since we only have one parameter in this example you will only have one listed under “env”.

*Note: For additional customization, the “icon” and “documentationUrl” fields can also be changed.*

Your YAML should look something like this:

```yaml
name: joeattorq/helloworld:1.0.0
id: hello_world
documentationUrl: https://knowyourmeme.com/memes/doge
icon: https://raw.githubusercontent.com/joe-at-torq/Torq-Steps/main/Icons/cool-doge.png
env:
 COMMAND: such command, much wow!
pretty_name: Hello World
isPrivate: false
```

---

Once you have made changes to your YAML configuration for the step and pressed save, you should see your new step and the parameter(s) you defined.

https://lh4.googleusercontent.com/Too7HPTbaO3zkrquc87_EXNdPSIV7-GYK8OWIEiWqe-Ee85TodtpWO1qUVliqPPJo9axYM1z2-dDp-6_-b4Xri6WG031-Ko4t_1FJPATcWKYTtFQL9BRsZ-ZlTG8bXIQjHaGOUH5bE1IngHpzmO7Ixk

Enjoy your new step!
