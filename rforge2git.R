#' Convert the trunk of an R-forge SVN repository to git
#' 
#' This function reorganizes an existing SVN repository from R-forge to a git repository. One 
#' or both of the repository paths can be specified. Assumes that git-svn has been installed, and 
#' that git can be called through the command line/terminal. Windows users may have to 
#' add the git binary location to their ENVIRONMENTAL VARIABLES. 
#' 
#' @param svn.repo a string pointing to the R-forge SVN repository. Generally of the form 
#'    \code{svn://svn.r-forge.r-project.org/svnroot/package/} or 
#'    \code{svn+ssh://developername@@svn.r-forge.r-project.org/svnroot/package/}. 
#' @param git.repo a remote location to push the git repository to
#' @param package instead of specifying \code{svn.repo} you can specify the desired package
#'    to clone, and the function will combine this with \code{svnroot.url}
#' @param svnroot.url URL to the generic root folder for SVN packages.
#' @param rev_num specific revision number. Use to make a specific cloning point from the svn
#'    repo. Default is to clone the entire repo
#' @param clean logical; remove extra material in the SVN repo? This will reorganize 
#'    the format into something more suitable for Github or Gitorious, including only the
#'    contents of the \code{pkg/} directory.
#' 
#' @authors Phil Chalmers [aut, cre], Michael Friendly [ctb]
#'
#' @warning At present, the function assumes that the directory in which the git version of 
#'    the SVN repo will be cloned does not exist.  
#'    This means that attempting to run the function twice in the current directory will fail.
#'
#' @examples
#' \dontrun{
#' 
#' # convert R-forge tableplot to git
#' svn.repo <- 'svn://svn.r-forge.r-project.org/svnroot/tableplot/'
#' rforge2git(svn.repo=svn.repo)
#'
#' # same, specifying only package
#' system('rm -rf tableplot')
#' rforge2git(package='tableplot')
#' 
#' # publish to an empty git remote location 
#' # (Note: this will not work on your computer since you must be an admin for the git repo) 
#' git.repo <- 'https://github.com/philchalmers/svntableplot.git'
#' rforge2git(git.repo=git.repo)
#' 
#' # or run both steps at once
#' rforge2git(svn.repo=svn.repo, git.repo=git.repo)
#' 
#' }
rforge2git <- function(svn.repo = NULL, git.repo = NULL,
                  package = NULL, svnroot.url = 'svn://svn.r-forge.r-project.org/svnroot/',
                  rev_num = NULL, clean = TRUE){
    
    # restore working directory at the end
    pwd <- getwd()
    on.exit(setwd(pwd))
    
    if(!is.null(package) && is.null(svn.repo) {
        svn.repo <- paste0(svnroot.url, package, '/')
    }
    if(is.null(svn.repo) && is.null(git.repo))
        stop('One or both of svn.repo or git.repo must be specified.')
    if(!is.null(svn.repo)){
        dir <- dir()
        if(is.numeric(rev_num)){
            gc <- sprintf('git svn clone -r %i:HEAD', rev_num)
        } else gc <- 'git svn clone '
        system(paste0(gc, svn.repo))
        reponame <- setdiff(dir(), dir)
        setwd(reponame)
        if(clean) system(paste0(c('rm -f -r', setdiff(dir(), 'pkg')), collapse=" "))
    	is_win <- Sys.info()['sysname'] == 'Windows'
    	if(is_win){
    	    wd <- getwd()
    	    wd <- gsub('/', '\\\\', wd)
    	    system(paste0('xcopy pkg ', paste0(wd, ' /s /e /h')))
    	    system('rm -f -r pkg')
    	} else {
    	    system('git mv pkg/* pkg/.[a-zA-Z]* .')
    	    system('rmdir pkg/')
        }
        system('touch README.md')
        system('git add --all')
        system('git commit -m "fixup initial migration from svn"')
    }
    
    # option to publish git repo
    if(!is.null(git.repo)){
        system(paste0('git remote add origin ', git.repo))
        system('git push -u origin master')
    }
    return(invisible(NULL))
}

