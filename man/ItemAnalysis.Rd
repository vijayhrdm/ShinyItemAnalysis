% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ItemAnalysis.R
\name{ItemAnalysis}
\alias{ItemAnalysis}
\title{Item Analysis}
\usage{
ItemAnalysis(data, y = NULL, k = 3, l = 1, u = 3,
maxscore, minscore, cutscore, add.bin = FALSE)
}
\arguments{
\item{data}{matrix or data.frame of items to be examined. Rows represent respondents, columns
reperesent items.}

\item{y}{vector of criterion values.}

\item{k}{numeric: number of groups to which may be data.frame x divided by the total score.
Default value is 3.  See \strong{Details}.}

\item{l}{numeric: lower group. Default value is 1. See \strong{Details}.}

\item{u}{numeric: upper group. Default value is 3. See \strong{Details}.}

\item{maxscore}{numeric or vector: maximal score in ordinal items. If missing, vector of obtained maximal scores is imputed. See \strong{Details}.}

\item{minscore}{numeric or vector: minimal score in ordinal items. If missing, vector of obtained minimal scores is imputed. See \strong{Details}.}

\item{cutscore}{numeric or vector: cut score used for binarization of ordinal data.
If missing, vector of maximal scores is imputed. See \strong{Details}.}

\item{add.bin}{logical: If TRUE, indices are printed also for binarized data. See \strong{Details}.}
}
\value{
\code{ItemAnalysis} function computes various traditional item analysis indices. Output
is a \code{data.frame} with following columns:
  \item{\code{diff}}{average score of the item divided by its range}
  \item{\code{avgSCore}}{average score of the item}
  \item{\code{SD}}{standard deviation of the item score}
  \item{\code{SDbin}}{standard deviation of the item score for binarized data}
  \item{\code{correct}}{proportion of correct answers}
  \item{\code{min}}{minimal score specified in \code{minscore}; if not provided, observed minimal score}
  \item{\code{max}}{maximal score specified in \code{maxscore}; if not provided, observed maximal score}
  \item{\code{obtMin}}{observed minimal score}
  \item{\code{obtMax}}{observed maximal score}
  \item{\code{cutScore}}{cut-score specified in \code{cutscore}}
  \item{\code{gULI}}{generalized ULI}
  \item{\code{gULIbin}}{generalized ULI for binarized data}
  \item{\code{ULI}}{discrimination with ULI using the usual parameters (3 groups, comparing 1st and 3rd)}
  \item{\code{ULIbin}}{discrimination with ULI using the usual parameters for binarized data}
  \item{\code{RIT}}{item-total correlation (correlation between item score and overall test score)}
  \item{\code{RITbin}}{item-total correlation for binarized data}
  \item{\code{RIR}}{item-rest correlation (correlation between item score and overall test score without the given item)}
  \item{\code{RIRbin}}{item-rest correlation for binarized data}
  \item{\code{itemCritCor}}{correlation between item score and criterion \code{y}}
  \item{\code{itemCritCorBin}}{correlation between item score and criterion \code{y} for binarized data}
  \item{\code{valInd}}{item validity index calculated as \code{cor(item, y)*sqrt(((N-1)/N)*var(item))}, see Allen & Yen (1979), Ch.6.4}
  \item{\code{valIndBin}}{item validity index for binarized data}
  \item{\code{rel}}{item reliability index calculated as \code{cor(item, test)*sqrt(((N-1)/N)*var(item))}, see Allen & Yen (1979), Ch.6.4}
  \item{\code{relBin}}{item reliability index for binarized data}

  \item{\code{relDrop}}{item reliability index 'drop' (scored without item)}
  \item{\code{relDropBin}}{item reliability index 'drop' (scored without item) for binarized data}
  \item{\code{alphaDrop}}{Cronbach's alpha without given item}
  \item{\code{alphaDropBin}}{Cronbach's alpha without given item, for binarized data}
  \item{\code{missedPerc}}{proportion of missed responses on the particular item}
  \item{\code{notReachPerc}}{proportion of respondents that did not reached the item nor the subsequent ones, see \code{\link{recode_nr}} function for further details}
With \code{add.bin == TRUE}, indices based on binarized data set are also provided
and marked with \code{bin} suffix.
}
\description{
\code{ItemAnalysis} function computes various traditional item analysis indices
including difficulty, discrimination and item validity. For ordinal items the difficulty and
discrimination indices take into account minimal item score as well as range.
}
\details{
For ordinal items the difficulty and discrimination indices take into account
minimal item score as well as range.

For calculation of discimination ULI index, it is possible to
specify the number of groups \code{k}, and which two groups \code{l} and \code{u}
are to be compared.

In ordinal items, difficulty is calculated as difference of average score divided by range
(maximal possible score \code{maxscore} minus minimal possible score \code{minscore}).

If \code{add.bin} is set to \code{TRUE}, item analysis of binarized data is
included in the output table. In such a case, \code{cutscore} is used for binarization.
When binarizing the data, values greater or equal to cut-score are set to \code{1},
other values are set to \code{0}.
}
\examples{
\dontrun{
# loading 100-item medical admission test data sets
data(dataMedical, dataMedicalgraded)
# binary data set
dataBin <- dataMedical[, 1:100]
# ordinal data set
dataOrd <- dataMedicalgraded[, 1:100]
# study success is the same for both data sets
StudySuccess <- dataMedical[, 102]

# item analysis for binary data
head(ItemAnalysis(dataBin))
# item analysis for binary data using also study success
head(ItemAnalysis(dataBin, y = StudySuccess))

# item analysis for binary data
head(ItemAnalysis(dataOrd))
# item analysis for binary data using also study success
head(ItemAnalysis(dataOrd, y = StudySuccess))
# including also item analysis for binarized data
head(ItemAnalysis(dataOrd,
  y = StudySuccess, k = 5, l = 4, u = 5,
  maxscore = 4, minscore = 0, cutscore = 4, add.bin = TRUE
))
}
}
\references{
Martinkova, P., Stepanek, L., Drabinova, A., Houdek, J., Vejrazka, M., & Stuka, C. (2017).
Semi-real-time analyses of item characteristics for medical school admission tests.
In: Proceedings of the 2017 Federated Conference on Computer Science and Information Systems.
https://doi.org/10.15439/2017F380

Allen, M. J. & Yen, W. M. (1979). Introduction to measurement theory. Monterey, CA: Brooks/Cole.
}
\seealso{
\code{\link{DDplot}}, \code{\link{gDiscrim}}, \code{\link{recode_nr}}
}
\author{
Patricia Martinkova \cr
Institute of Computer Science of the Czech Academy of Sciences \cr
\email{martinkova@cs.cas.cz} \cr

Jan Netik \cr

Jana Vorlickova \cr

Adela Hladka \cr
Institute of Computer Science of the Czech Academy of Sciences \cr
Faculty of Mathematics and Physics, Charles University \cr
\email{hladka@cs.cas.cz} \cr
}
