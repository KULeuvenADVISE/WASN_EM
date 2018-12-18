Contributing
============

How to contribute
-----------------

The preferred way to contribute to `WASN_EM` is to fork the 
[main repository](https://github.com/gertdekkers/WASN_EM) on
GitHub:

1. Fork the [project repository](https://github.com/gertdekkers/WASN_EM):
   click on the 'Fork' button near the top of the page. This creates
   a copy of the code under your account on the GitHub server.

2. Clone this copy to your local disk:

        git clone git@github.com:[YOUR_LOGIN]/WASN_EM.git
        cd dcase_util 

3. Create a branch to hold your changes:

        git checkout -b my-new-feature

   and start making changes. You should never work in the ``master`` branch directly. 

4. Work on this copy on your computer using Git to do the version
   control. When you're done editing, do:

        git add [MODIFIED FILES]
        git commit

   to record your changes in Git, then push them to GitHub with:

        git push -u origin my-new-feature

Finally, go to the web page of the your fork of the WASN_EM repo,
and click 'Pull request' to send your changes to the maintainers for
review. This will send an email to the committers.

More information about this kind of process can be found in 
[Git documentation](http://git-scm.com/documentation).

Note
----
This document is based on contribution instructions for [DCASE utilities](https://github.com/DCASE-REPO/dcase_util).
