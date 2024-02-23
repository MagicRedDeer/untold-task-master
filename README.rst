Untold Task Master
==================

My very own task manager at Untold

.. image:: ./Untold_task_master.png
   :width: 400
   :alt: Cactus on task master's chair



Basic Usage
===========

::

  > utm -h 

  Usage:
  ======
  utm [--verbose|-v|--help|-h] <command> <options>

  Valid commands:
  ---------------
  create
  remove
  activate
  retire
  revive
  active
  list
  repo
  config
  dir
  cd
  build
  run
  attach


Concepts
========

What is a task?
  A task is a unit of work based on a ticket assigned to you. UTM enables you
  to work on multiple tasks at the same time by providing you the ability to
  switch between them.

Is a task related to one repository?
  A task may involve manipulation of more than one repositories. So a task
  directory would contain more than one repository.

What is a task composed of?
  A task is contained in a directory in `UTM_TASKS_DIR` which defaults to
  `~/Workspace/Tasks/`. A task may compose of repos cloned to their pipeline
  positions and a pipeline-config directory having a config.json file. There
  could be some more useful metadata and management files found in a task.

  A Task directory is basically a copy of the instance of a `~/pipeline`
  directory.
 
What is an active task?
  An active task is the one that you are currently working on. There can be
  only onen active task. This is the task linked to by a symlink in the
  location `~/pipeline`. This is the location being used after you invoke the
  `set_dev` command at the bash interface.

  A task can be made `active` with the use of the command `utm activate`

What is a retired task?
  A retired task is one you have finished working with and does not require
  anymore work. A retired task cannot be made `active` unless it has been
  revived.

What is a live task?
  An existing task which has not been retired is a live task.

What is a task build?
  A task build is a snapshot of a task code and configurtation in any place.
  Task builds are placed inside a `task build` directory which defaults to
  `~/.task_builds`. Builds are typically arranged by the name of a task and
  their timestamps.

  A Build can be used to create a deployment for a task for testing, and the
  developer can keep on working more changes on the task.

  A **live** build is the same as the one a developer is working. A **latest**
  build is the latest snapshot found in the build directory.

  This uses the functionality provided by the `lf build` option under the hood.
  Builds can be used to `run` a specific command inside a build.


Meta-Task Commands
==================

Here we list all commands that are related to creation, deletion, activation
and retiring of tasks

utm create
----------

This command creates a new task. The task is created live and made active.

* Task of the given name should not exist otherwise it should Error out
* No completions required

::

  > utm create PIPE-2000_terminate_everything
  active task is set to: PIPE-2000_terminate_everything


utm remove
----------

This command removes an existing task. Deletes the entire contents from the disk.

* Task should exist and not be active otherwise an error should be shown
* Completion the word after utm remove (fuzzily) after remove with all existing
  tasks

utm retire
----------

Retire the provided task. It will not show up in activate completions and
live task lists. It will not longer be possible to make the task active
unless revived using the `utm revive` command.

* Provided task should exist and also be live
* Completions provided with live tasks only

utm revive
----------

Revive a retired task. 

* Provided task should exist and be retired
* Completions provided with retired tasks only


utm activate
------------

Make the provided task active

* Provided task should exist and be activte
* Completions provided with live tasks only


utm active
----------

Prints the name of the currently active task.


utm list
--------

Prints a list of existing tasks

* If no flag is provided list all live tasks only
* If the `--retired` or `-r` flag is provided list all retired tasks.
* If the `--all` or `-a` flag is provided list all existing tasks.

Task Management commands
========================

The commands listed here are concerned manipulation inside a task. They will
refer to the currently active task unless specified otherwise using the
`--task` or `-t` flags.

For all commands mentioned below the `-f` flag will be completed with live
tasks.

utm repo
-----------

Command for adding and removal of repos inside the task.  

utm repo add
++++++++++++

It will add the repo to a corresponding lionfish environment and as well as
clone the concerned repository in the appropriate location inside the task. It
will also use lionfish to generate `pipeline-config` json file as well.

Completion provided for all possible names of the repositories
Should be able to take multiple repo names

utm repo remove
+++++++++++++++

It will remove the repo from a corresponding lionfish environment and as
well as remove the clone of the concerned repository from the appropriate
location inside the task. It will also use lionfish to generate
`pipeline-config` json file as well.

Completion provided from all the existing repos
Should be able to take multiple repo names

utm repo list
++++++++++++++++

It will list all packages command between lionfish and clones

utm build
---------
Create a lionfish build of the task in the task build directory. Builds are
arranged by tasks and timestamps

The following flags are acceptable:

--name or -n
  name of the current build. If the name is not provided build will be created
  with a timestamp anyway. **live** and **latest** are not acceptable. Should
  be a valid file/directory name.

::

  > utm build -n test_build


--deploy or -d [TODO]
  This will deploy the **latest** or the provided build to the given directory
  location.

::

  > utm build -d /software/installed/Temporary/ -n test_build

utm run
-------

Run the provided command in the given build. If no build is provided it
defaults to the **live** build.


The following flags are accepted:

--name or -n
  The name of the build to run with. Completed with all existing build names.

--python or -p
  The version of python setup in the environment

--job or -j
  cd to the provided job name before execution

::

  > utm run --job untold_pipeAlpha_10395 --name test_build stem-ingest -e

utm attach
----------
For attaching a tmux session for the task

utm dir
--------
Return the full directory path of the task

utm cd
------
change to the directory of the task


Dependencies
============

* bash
* Lionfish
* untold_shell
* jq
* realpath
* tmux
* other shell utilities
