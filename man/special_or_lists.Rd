\name{special_or_lists}
\alias{special_or_lists}
\title{OR two lists together with some regards for nesting}
\usage{
special_or_lists(list1, list2)
}
\arguments{
  \item{list1}{a list.}

  \item{list2}{a list.}
}
\value{
the or'ed list.
}
\description{
The structure of the lists should be the same. That is, as
a tree, the two lists should be isomorphic. For example,
\code{special_or_lists(list(a = FALSE, b = list(b = TRUE, c
= FALSE)), list(a = FALSE, b = list(b = FALSE, c = TRUE)))}
yields \code{list(a = FALSE, b = list(b = TRUE, c = TRUE))}
and \code{special_or_lists(list(a = FALSE, b = list(b =
TRUE, c = FALSE)), list(a = list(b = FALSE, c = TRUE), b =
FALSE))} yields \code{list(a = list(b = FALSE, c = TRUE), b
= list(b = TRUE, c = FALSE))}
}
\details{
Note that lists get ORed based on *order*, not on key names
(as this could be ambiguous), so make sure the two lists
have the same comparable key orders. For example,
\code{special_or_lists(list(a = TRUE, b = FALSE), list(b =
FALSE, a = TRUE))} would mistakenly return \code{list(a =
TRUE, b = TRUE)}.
}

