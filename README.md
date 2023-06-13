
# HelloID-Conn-Prov-Target-Moodle

| :warning: Warning |
|:---------------------------|
| Note that this connector is "a work in progress" and therefore not ready to use in your production environment. |

| :information_source: Information |
|:---------------------------|
| This repository contains the connector and configuration code only. The implementer is responsible to acquire the connection details such as username, password, certificate, etc. You might even need to sign a contract or agreement with the supplier before implementing this connector. Please contact the client's application manager to coordinate the connector requirements. |

<p align="center">
  <img src="https://www.tools4ever.nl/connector-logos/moodle-logo.png" width="500">
</p>

## Table of contents

- [HelloID-Conn-Prov-Target-Moodle](#helloid-conn-prov-target-moodle)
  - [Table of contents](#table-of-contents)
  - [Introduction](#introduction)
  - [REST API](#rest-api)
    - [Lifecycle events](#lifecycle-events)
  - [Getting started](#getting-started)
    - [Add web service](#add-web-service)
    - [Manage token](#manage-token)
    - [Test connection](#test-connection)
    - [Debugging](#debugging)
  - [Connection settings](#connection-settings)
    - [Prerequisites](#prerequisites)
    - [Remarks](#remarks)
      - [Account mapping](#account-mapping)
      - [Accounts retrieved based on `$account.email`](#accounts-retrieved-based-on-accountemail)
      - [Creation / correlation process](#creation--correlation-process)
  - [Getting help](#getting-help)
  - [HelloID docs](#helloid-docs)

## Introduction

_HelloID-Conn-Prov-Target-Moodle_ is a _target_ connector. Moodle is an open source learning management system (LMS) that provides a platform for creating and managing online courses and educational resources. Moodle offers web services APIs that allow developers to access and integrate the functionality of Moodle with other applications and systems.

## REST API

The Moodle REST API uses a RESTful architecture, where each action is represented as a URL endpoint and the HTTP method (GET, POST, PUT, DELETE, etc.) is used to indicate the desired operation. The parameters for the action should be included in the request body in JSON format. For example, to create a new user in Moodle, you could send a POST request to the `/webservice/rest/server.php?moodlewsrestformat=json&wsfunction=core_user_create_users` endpoint, with the user information in the request body as follows:

```json
{
  "users": [
    {
      "username": "johnsmith",
      "password": "mypassword",
      "firstname": "John",
      "lastname": "Smith",
      "email": "john.smith@example.com",
      "auth": "manual"
    }
  ]
}
```

### Lifecycle events

The following lifecycle events are available:

| Event  | Description | Notes |
|---	 |---	|---	|
| create.ps1 | Create (or update) and correlate an account | - |

## Getting started

In order to use the Moodle REST API, a web service must be created with the correct functions / capabilities and corresponding users who are allowed to access the API.

### Add web service

To add a new web service:

Go to the `Site administration > Server > Web Services > External services` section.

When creating a new web service, you will need to provide a name for the service, as well as a short description and choose which function or capabilities the service will have access to.

The HelloID connector uses the API functions listed in the table below.

| Functions     | Description |
| ------------ | ----------- |
| core_user_get_users_by_field | Get users by specific field |
| core_user_create_users | Create new users |
| core_user_update_users | Update users by specific field |
| core_webservice_get_site_info | Gets site info for testing the webservice |

### Manage token

To add a new token:

Go to the `Site administration > Server > Web Services > Manage tokens` section.

1. Click on the `Create token` button to create a new token.
3. Select the desired user and service, and provide a name for the token.
4. Click on the `Save changes` button to generate the token.

> :exclamation: It's important to note that the specific steps for creating a web service and token may vary depending on the version of Moodle you are using, as well as any additional plugins or customizations you have installed on your site. It may be helpful to consult the documentation or support resources for your specific Moodle setup if you need more detailed instruction.

### Test connection

To test the newly created token:

Go to the `Site administration > Development > Web service test client` section.

1. Set the `authentication` method to `token`.
2. Choose to choose the `REST` protocol.
3. Select the function `core_webservice_get_site_info` and click `select`.
4. Paste your token and click `Execute`.

### Debugging

If the connection to moodle is not established, you can toggle debug logging.

Go to the `Site administration > Development > Debugging` section.

At the section `Debug messages` select the option `DEVELOPER: extra Moodle debug messages for developers`

## Connection settings

The following settings are required to connect to the API.

| Setting| Description| Example | Mandatory  |
| ------------ | -----------| ----------- | ----------- |
| Token | The Token to connect to the API | 0ab0000c00000000000d00000e000000  |Yes
| BaseUrl | The URL to the API | http://localhost | Yes

### Prerequisites

- [Webservice](#add-web-service)
- [API Token](#manage-token)

### Remarks

#### Account mapping

Currently, the account mapping only contains basic information. You will need to adjust this accordingly.

> :exclamation: be aware that the `password` is mandatory and cannot be left empty.

```powershell
# Account mapping
$account = [PSCustomObject]@{
    username  = 'stuntman14'
    firstname = $p.Name.GivenName
    lastname  = $p.Name.FamilyName
    email     = $p.Contact.Business.Email

    # The password is a mandatory field and cannot be left empty
    password  = ''
}
```

#### Accounts retrieved based on `$account.email`

Currently, accounts are retrieved using the `email` parameter.

#### Creation / correlation process

A new functionality is the possibility to update the account in the target system during the correlation process. By default, this behavior is disabled. Meaning, the account will only be created or correlated.

You can change this behavior in the `create.ps1` by setting the boolean `$updatePerson` to the value of `$true`.

> Be aware that this might have unexpected implications.

## Getting help

> _For more information on how to configure a HelloID PowerShell connector, please refer to our [documentation](https://docs.helloid.com/hc/en-us/articles/360012558020-Configure-a-custom-PowerShell-target-system) pages_

> _If you need help, feel free to ask questions on our [forum](https://forum.helloid.com)_

## HelloID docs

The official HelloID documentation can be found at: https://docs.helloid.com/
