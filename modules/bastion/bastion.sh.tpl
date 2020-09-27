#!/bin/bash
yum -y update
%{ for x in programs_to_install ~}
yum -y install ${x}
%{ endfor ~}



