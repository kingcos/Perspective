# Practice - iOS 项目持续集成实践（一）

![CI in Practice](https://github.com/kingcos/Perspective/blob/writing/Posts/Practice/CI_Practice_in_iOS/1/image.png?raw=true)

## Preface

一个软件工程项目从编写、到测试、再最终交付到用户通常有很多重复且固定的步骤。虽然作为开发者，我们的核心任务是编写代码，而这些其他的步骤却也不能忽视，持续集成（Continuous Integration）则可以帮助开发者完成这些琐碎的事务，提升团队的开发效率与质量。

本文将主要介绍持续集成是什么，以及其中的好处。当然，您可能也注意到了标题后面「（一）」，没错，持续集成并非一篇文章可以概括，笔者希望尽可能将目前团队中使用到的和持续集成相关的内容进行总结，目的是为了让大家一起思考如何让持续集成更好地服务我们开发。当然，限于笔者能力，文中不免出现遗漏，也望读者能够批评和指出。

## What

持续集成，译自 Continuous Integration，简称 CI（在下文中，将统一使用该英文简称）。在 Wikipedia 中，也有针对 CI 特别详细且专业的介绍。简而言之，当开发者通过版本控制系统（例如 Git）提交了代码，CI 系统将为其自动执行构建、分析、测试等服务，当前面的服务一致通过，其也能直接将产品部署到生产环境，而后进入下一个循环。其中每一步都将自动触发、执行，结果也将会自动反馈回开发者。正如下图所示，CI 的重点在于 C——持续。

![CI](https://github.com/kingcos/Perspective/blob/writing/Posts/Practice/CI_Practice_in_iOS/1/1.png?raw=true)

## Why & Why not

那么为什么需要 CI 呢？相比于传统的先开发，再测试，后上线的模式有哪些好处呢？在团队使用 CI 这段时间中，得出了以下主要两个好处：

1. 及时发现错误。CI 并不能消除错误，但 CI 将发现错误的时机尽可能地提前，所以也更加节省时间来改正错误。当开发者提交代码至代码仓库时，其对于代码的熟悉程度是最高的。如果这个时候尽可能的纠正一些错误或不当，开发者将能很快注意到并将错误改正，避免了由于时间或者团队中其他人对于代码的修改所导致的问题，提升了开发效率。
2. 自动化。市面上的 CI 平台都给了开发者比较高的自由度，能够执行脚本或命令。因此很多自动化的操作都可以制定好，来自动化地执行，节省开发者的时间。

如果这两个显而易见的好处还不足以说服，可以参考文末 Reference 中 EKATERINA NOVOSELTSEVA 的文章。那么 CI 会不会也存在什么难处呢？

1. 跨技术栈。CI 并不特定于前端或者后端，CI 通常根据不同的平台而有很多不同，包括配置的方法、使用的语言、自由度等等。CI 又和 Docker 的发展有一定的关系，因此跨技术栈可能让一些团队望而却步。不过好的是，DevOps（Development & Operations）也在国内渐渐兴起，越来越被重视。
2. 跨平台。这里所指的平台是指代码托管平台、CI 平台、以及部署平台。在公司开始时，可能并不能轻易考虑到后续的发展，因此在原有平台加入 CI 可能需要跨平台的协作。对于一些「黑盒」的平台，有时便难以很好的集成。不过，现在 Git 的两大平台 GitHub 和 GitLab 都很重视且支持 CI 平台，也便于开发者使用。

如果后面两个问题并没有阻挠你，那么就开始尝试 CI 吧～

## How

CI 并不依赖于某种特定的技术栈，其属于一种编程范式。但是，具体谈及如何实践，这就需要结合不同的工具和业务，进行定制。

### Jenkins

![Jenkins](https://github.com/kingcos/Perspective/blob/writing/Posts/Practice/CI_Practice_in_iOS/1/2.png?raw=true)

Jenkins 是一款使用 Java 开发且开源的持续集成工具，很多 iOS 团队内部都会使用 Jenkins & Fastlane 来自动化打包。因为 Jenkins 是开源的，可以方便地部署在自己的服务器中，而且也有很多插件来辅助不同的技术栈和功能需求。Swift 官方也使用了 Jenkins 作为自己的 CI。

![ci.swift.org](https://github.com/kingcos/Perspective/blob/writing/Posts/Practice/CI_Practice_in_iOS/1/3.png?raw=true)

### GitHub with Travis CI

![Travis CI](https://github.com/kingcos/Perspective/blob/writing/Posts/Practice/CI_Practice_in_iOS/1/4.png?raw=true)

GitHub，人尽皆知，是全球最大的代码托管平台，但 GitHub 本身并没有集成 CI。但有很多 CI 平台为 GitHub 定制 CI 环境，其中使用较多的便是 Travis CI。在 GitHub 仓库中看到有 `.travis.yml` 文件便意味着该仓库集成了 Travis CI。对于开源的项目，可以选择它就不用开发者再单独配置服务器来运作 CI，当然速度可能会慢些。之前在写个人的一个命令行工具时，便尝试使用了 Travis CI，而且可以非常容易的将 CI 状态和代码覆盖率的 Budge 标示在项目文档中。

![kingcos/WWDCHelper](https://github.com/kingcos/Perspective/blob/writing/Posts/Practice/CI_Practice_in_iOS/1/5.png?raw=true)

### GitLab with CI

![GitLab](https://github.com/kingcos/Perspective/blob/writing/Posts/Practice/CI_Practice_in_iOS/1/6.png?raw=true)

相比于上述的几个平台，GitLab 真正把代码托管和 CI 结合了起来，并在最新 Release 版中加入了 Auto DevOps，似乎是更加先进的 CI。团队内部目前使用的便是 GitLab EE，后续就将以 GitLab 为主，讲讲其中配合 GitLab Runner 来规范化开发流程。

## Reference

- [Continuous integration - Wikipedia](https://en.wikipedia.org/wiki/Continuous_integration)
- [Top benefits of continuous integration - EKATERINA NOVOSELTSEVA](https://apiumtech.com/blog/top-benefits-of-continuous-integration-2/)
- [Jenkins](https://jenkins.io)
- [Travis CI](https://travis-ci.org)
- [GitLab](https://gitlab.com)