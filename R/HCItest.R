#' Homeostasis Concept Inventory Dataset
#'
#' @description (\code{HCItest}) dataset consists of the responses of 651 students (405 males,
#' 246 females) to Homeostasis Concept Inventory (HCI) multiple-choice test. It containts 20
#' items, vector of gender membership and identificator whether students plan to major.
#'
#' @usage data(HCItest)
#'
#' @author
#' Jenny L. McFarland \cr
#' Biology Department, Edmonds Community College
#'
#' @references
#' McFarland, J. L., Price, R. M., Wenderoth, M. P., Martinkova, P., Cliff, W., Michael, J., ... & Wright, A. (2017).
#' Development and validation of the homeostasis concept inventory. CBE-Life Sciences Education, 16(2), ar35.
#'
#' @keywords datasets
#'
#' @seealso \code{\link{HCI}}, \code{\link{HCIkey}}
#'
#' @format \code{HCItest} is a \code{data.frame} consisting of 651 observations on the 22 variables.
#' \describe{
#' \item{Item1-Item20}{multiple-choice items of the HCI test.}
#' \item{gender}{gender membership vector, \code{"0"} males, \code{"1"} females.}
#' \item{major}{identificator whether students planning to major in the life sciences.}
#' }
"HCItest"
