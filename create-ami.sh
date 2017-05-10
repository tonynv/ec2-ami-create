TAG="develop"
INSTANCE_ID="i-033728a6d2897f2ff"
REGION="us-west-2"
TYPE="Develop"
NAME="App ${TYPE} $(date +%F)"

AMIID=$(aws ec2 create-image --instance-id "${INSTANCE_ID}" --no-reboot --name="${NAME}" --description "QuickStart CI Automated backup - Contains Confidential Data" --region=${REGION} --output text)
sleep 5;
echo "Created AMI ${AMIID}"
ROOT_SNAP=$(aws ec2 describe-images --image-id  $AMIID  --region ${REGION} --output text | grep EBS |grep 32 | awk '{print $4}')
echo "Root snapid ${ROOT_SNAP}"
EBS1=$(aws ec2 describe-images --image-id  $AMIID  --region ${REGION} --output text | grep EBS |grep 100 | awk '{print $4}')
echo "EBS1 snapid ${EBS1}"

# Wait for image to become available

READY=$(aws ec2 describe-images --image-id  $AMIID  --region ${REGION} | grep State |awk '{print $NF}' | grep -c available)
while (test $READY -eq 0)
do
echo "Waiting on snapshot to complete" ; sleep 2;
READY=$(aws ec2 describe-images --image-id  $AMIID  --region ${REGION} | grep State |awk '{print $NF}' | grep -c available)
done

aws ec2 create-tags --resources ${ROOT_SNAP} --tags Key="Name",Value="${AMIID} (boot)" Key="Type",Value="${NAME}"  --region=${REGION} 
aws ec2 create-tags --resources ${EBS1} --tags Key="Name",Value="${AMIID} (lvm)" Key="Type",Value="${NAME}" --region=${REGION} 
aws ec2 create-tags --resources $AMIID --tags Key="Name",Value="${TAG}" Key="Type",Value="${TYPE}" --region=${REGION} 
