#!/bin/bash

####################################  Variables  #####################################
pagesDir=pages
commonsDir=common-parts
styleDir=style
targetDir=./target
docsDir=docs
labHtml=pages/lab.html


####################################  Declaring Maps  #################################
menubarPagesMap=()
staticPagesMap=()
####################################  Functions  #####################################

cleanTargetDir(){
   echo "Creating fresh target dir ${targetDir}"
   rm -rf ${targetDir}
   mkdir -p ${targetDir}
}

creatingEmptyHTML () {
      pageHtmlFilename=$1
      echo ""
      echo "Creating empty ${targetDir}/${pageHtmlFilename}"
      touch ${targetDir}/${pageHtmlFilename}
}

updatingWithCommon () {
   pageHtmlFilename=$1
   srcFileAbsolutePath=$2
   echo "Adding to ${targetDir}/${pageHtmlFilename} the ${srcFileAbsolutePath}"

   if [ -f ${srcFileAbsolutePath} ] ; then
      cat ${srcFileAbsolutePath} >> ${targetDir}/${pageHtmlFilename}
   else
      echo "File ${srcFileAbsolutePath} does not exist"
      exit 1
   fi
}

addMenuBar () {
   pageHtmlFilename=$1

   for menubarMapping in "${menubarPagesMap[@]}" ; do
      menubarFName="${menubarMapping%%:*}"
      menubarTitle="${menubarMapping##*:}"
      if [[ "${pageHtmlFilename}" == "${menubarFName}" ]] ; then
         echo "          <li class='selected'><a href='${menubarFName}'>${menubarTitle}</a></li>" >> ${targetDir}/${pageHtmlFilename}
      else
         echo "          <li><a href='${menubarFName}'>${menubarTitle}</a></li>" >> ${targetDir}/${pageHtmlFilename}
      fi
   done
}

addPageContent () {
   srcParentDir=$1
   srcFilename=$2
   dstParentDir=$3
   dstFilename=$4
   title=$5

   if [ -f ${srcParentDir}/${srcFilename} ] ; then
      echo "Adding to ${dstParentDir}/${dstFilename} page content from ${srcParentDir}/${srcFilename} "
      cat ${srcParentDir}/${srcFilename} >> ${dstParentDir}/${dstFilename}
   else
      echo "Adding to ${dstParentDir}/${dstFilename} empty page content"
      echo "        <h2>${title}</h2>"      >> ${dstParentDir}/${dstFilename}
      echo "        <p>Strona w budowie</p>" >> ${dstParentDir}/${dstFilename}
   fi
}

copyStyleAndDocsAndImagesAndLabPage () {
   cp -fr ${styleDir} ${targetDir}
   cp -fr ${docsDir} ${targetDir}
   cp -fr ${labHtml} ${targetDir}
}

verifyHtmlSyntax () {
   echo ""
   for eachHtmlFile in ${targetDir}/*.html ; do

      tidy -utf8 -q -e -xml ${eachHtmlFile}
      exitCode=$?
      if [ ${exitCode} -eq 2 ] ; then
         echo ""
         echo "FAILURE: HTML syntax is incorrect in ${eachHtmlFile}"
         exit ${exitCode}
      else
         echo "HTML syntax is OK in ${eachHtmlFile}"
      fi
   done
   echo ""
   echo "SUCCESS"
}

addUpdateDateAndTime () {
   pageHtmlFilename=$1
   echo "Adding to ${targetDir}/${pageHtmlFilename} the last date of modification"
   echo "Data ostatniej modyfikacji: $(date +'%Y-%m-%d %H:%M:%S')" >> ${targetDir}/${pageHtmlFilename}
}


generatePage(){
       filename=$1
       title=$2

       creatingEmptyHTML        "${filename}"
       updatingWithCommon       "${filename}"  ${commonsDir}/header.txt
       addMenuBar               "${filename}"
       updatingWithCommon       "${filename}"  ${commonsDir}/news-start.txt

       updatingWithCommon       "${filename}"  ${commonsDir}/news.txt

       updatingWithCommon       "${filename}"  ${commonsDir}/news-end.txt

       updatingWithCommon   "${filename}"  ${commonsDir}/sidelogo.txt

       updatingWithCommon   "${filename}"  ${commonsDir}/pagecontent-start.txt

       addPageContent       "${pagesDir}"   "${filename}"   "${targetDir}"  "${filename}"  "${title}"

       updatingWithCommon       "${filename}"  ${commonsDir}/updatebar.txt
       addUpdateDateAndTime     "${filename}"
       updatingWithCommon       "${filename}"  ${commonsDir}/footer.txt
}

main () {
   cleanTargetDir

   menubarPagesMap=( "index.html:Kontakt"
                  "czlonkowie.html:Członkowie zespołu"
                  "badania.html:Badania"
                  "publikacje.html:Publikacje"
                  "prace_dyplomowe.html:Prace dyplomowe"
                  "dydaktyka.html:Dydaktyka"
                  )


   staticPagesMap=( "index.html:Kontakt"
                  "czlonkowie.html:Członkowie zespołu"
                  "badania.html:Badania"
                  "publikacje.html:Publikacje"
                  "prace_dyplomowe.html:Prace dyplomowe"
                  "dydaktyka.html:Dydaktyka"
                  )

   # generating main pages
   for mainPage in "${staticPagesMap[@]}" ; do
       filename="${mainPage%%:*}"
       title="${mainPage##*:}"
       generatePage "${filename}" "${title}"
   done

   copyStyleAndDocsAndImagesAndLabPage

   verifyHtmlSyntax
}

main