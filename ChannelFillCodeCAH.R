### Inputs

data = read.csv("C:/Users/user/Desktop/Projects/Channel_flling/Algo_CAH_channel_filling/data.csv", sep=",",header=TRUE)
data=data

RevenueReportables_Channelfill='Reportables'
CustomerType_trend_Channelfill='Public'
Family_trend_Channelfill=unique(data$Family[which(data$type%in%CustomerType_trend_Channelfill)])
ParameterPanel_Channelfill=unique(data$ParameterPanel[which(data$Family%in%Family_trend_Channelfill)])
Gpch_Channelfill=unique(data$Gpch[which(data$ParameterPanel%in%ParameterPanel_Channelfill)])

PotentialScorethreshold=5
ClusterSize=2

### Data preprocess and filtering
PcSpread=data
PcSpread=PcSpread[,c('type','Customer.Num','Family','ParameterPanel','Gpch',RevenueReportables_Channelfill)]

# filtering based on customer type, family, parameterpanel, gpch
PcSpread=PcSpread[which(PcSpread$type%in%CustomerType_trend_Channelfill 
                        &PcSpread$Family %in% Family_trend_Channelfill
                        & PcSpread$ParameterPanel%in%ParameterPanel_Channelfill 
                        &PcSpread$Gpch %in%Gpch_Channelfill),]
PcSpread=PcSpread[,c('Customer.Num','Gpch',RevenueReportables_Channelfill)]

PcSpread=aggregate(formula(paste0(RevenueReportables_Channelfill,"~Customer.Num+Gpch")),data=PcSpread,sum)

PcSpread=tidyr::spread(PcSpread,key=Gpch,value=RevenueReportables_Channelfill)
PcSpread[is.na(PcSpread)]=0
PcSpread=as.data.frame(PcSpread)
rownames(PcSpread)=PcSpread$Customer.Num
PcSpread$Customer.Num=NULL

### Data used for clustering
flexiPcSpreadSub=PcSpread


### Clustering:
flexiPCSpreadSubM=flexiPcSpreadSub[,names(which(colSums(flexiPcSpreadSub[,setdiff(colnames(flexiPcSpreadSub),c('Customer.Num'))])>0))]

if (nrow(flexiPCSpreadSubM)>=3)
{
  flexiPCSpreadSubM[flexiPCSpreadSubM<0]=0
  flexiPCSpreadSubM=scale(flexiPCSpreadSubM)
  
  #### Parameter Clustering
  paramClust=hclust(dist(t(flexiPCSpreadSubM)),method = 'ward.D2')
  
  Channelfill=data.frame()
  for (cutreeParam in c(0.1, 0.4, 0.7,0.85, 1, 1.3,-0.1,-0.4, -0.7, -1, -1.3))
  {
    
    h = (mean(paramClust$height+cutreeParam*sd(paramClust$height)))
    if (h<0)
    {
      h=0
    }
    
    membParam <- cutree(paramClust, h = (mean(paramClust$height+cutreeParam*sd(paramClust$height))))
    membParamTab=table(membParam)
    
    #### Channel filling activities. Find islands
    flexiChannelFillA_Param_tmp=NULL
    
    for (i in which(membParamTab>=ClusterSize))
    {
      clusterParam=names(membParamTab[i])
      paramMemb=names(which(membParam==clusterParam))
      flexiPcSpreadSubMSub=flexiPCSpreadSubM[,paramMemb]
      
      #### Hospital Clustering
      hospClust=hclust(dist(flexiPcSpreadSubMSub),method = 'ward.D2')
      
      flexiChannelFillA_Hosp_tmp=NULL
      
      for (cutreeHosp in c(0.1, 0.4, 0.7,0.85, 1, 1.3,-0.1,-0.4, -0.7, -1, -1.3))
      {
        h = (mean(hospClust$height+cutreeHosp*sd(hospClust$height)))
        if (h<0)
        {
          h=0
        }
        membHosp <- cutree(hospClust, h = h)
        hospClustOrder=hospClust$labels[hospClust$order]
        membHospTab=table(membHosp)
        
        flexiChannelFillA=NULL
        
        for (j in which(membHospTab>=ClusterSize))
        {
          clusterHosp=names(membHospTab[j])
          hospMemb=names(which(membHosp==clusterHosp))
          flexiPcSpreadSubSub=flexiPcSpreadSub[which(rownames(flexiPcSpreadSub) %in% hospMemb),paramMemb]
          flexiPcSpreadSubSub=flexiPcSpreadSubSub[,names(which(colSums(flexiPcSpreadSubSub)!=0)),drop=FALSE]
          
          if (nrow(flexiPcSpreadSubSub)>0)
          {
            if (length(which(flexiPcSpreadSubSub==0))!=nrow(flexiPcSpreadSubSub)*ncol(flexiPcSpreadSubSub) & length(which(flexiPcSpreadSubSub!=0))!=nrow(flexiPcSpreadSubSub)*ncol(flexiPcSpreadSubSub))
            {
              # Calculate potential score
              PotentialScore=round(length(which(flexiPcSpreadSubSub!=0))/length(which(flexiPcSpreadSubSub==0)),2)
              
              if (PotentialScore>PotentialScorethreshold)
              {
                fillTmp=data.frame(which(flexiPcSpreadSubSub ==0, arr.ind = T))
                fillTmp$Param=colnames(flexiPcSpreadSubSub)[fillTmp$col]
                fillTmp$Customer.Num=rownames(flexiPcSpreadSubSub)[fillTmp$row]
                paramMedian=apply(flexiPcSpreadSubSub,2,function(x) median(x[which(x>0)]))
                # Suggested expected reportables for channel fill
                fillTmp$ExpAvgReportables=paramMedian[fillTmp$Param]
                fillTmp$PotentialScore=PotentialScore
                fillTmp$scoreDetails=sprintf("%d = %d vs %d",nrow(flexiPcSpreadSubSub)*ncol(flexiPcSpreadSubSub),length(which(flexiPcSpreadSubSub!=0)) , length(which(flexiPcSpreadSubSub==0)))
                fillTmp$clusterParamList=list(paramMemb)
                fillTmp$clusterCustomerList=list(hospMemb)
                fillTmp$row=NULL
                fillTmp$col=NULL
                names(fillTmp)[which(names(fillTmp)=='ExpAvgReportables')]=paste0('ExpAvg',RevenueReportables_Channelfill)
                fillTmp=fillTmp[which(fillTmp[,paste0('ExpAvg',RevenueReportables_Channelfill)]>0),]
                flexiChannelFillA=rbind(flexiChannelFillA,fillTmp)
              }
            }
          }
        }
        
        flexiChannelFillA_Hosp_tmp=rbind(flexiChannelFillA_Hosp_tmp,flexiChannelFillA)
      }
      
      flexiChannelFillA_Param_tmp=rbind(flexiChannelFillA_Param_tmp,flexiChannelFillA_Hosp_tmp)
    }
    
    Channelfill=rbind(Channelfill,flexiChannelFillA_Param_tmp)
  }
  ChannelFillNested=Channelfill
  ChannelFillNested <- ChannelFillNested[order(ChannelFillNested$Param,ChannelFillNested$Customer.Num, -(ChannelFillNested$PotentialScore) ), ]
  ChannelFillNested=ChannelFillNested[!duplicated(ChannelFillNested[,c('Param','Customer.Num')]),]
}else{
  ChannelFillNested=NULL
}

  