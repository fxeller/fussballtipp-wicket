package de.delmak.fussballtipp.persistence;

import java.util.Date;

public class BracketMinDatetime extends HibernateObject
{

	private Integer bracketId;

	public Integer getBracketId()
	{
		return bracketId;
	}

	public void setBracketId(Integer bracketId)
	{
		this.bracketId = bracketId;
	}

	private Date datetime;

	public Date getDatetime()
	{
		return datetime;
	}

	public void setDatetime(Date datetime)
	{
		this.datetime = datetime;
	}

	@Override
	public String toString()
	{
		return String.format("%s_%s", getClass().getName(), getBracketId());
	}
	
	@Override
	public boolean equals(Object obj)
	{
		return obj.toString().equals(toString());				
	}

	@Override
	public int hashCode()
	{
		return toString().hashCode();
	}
	
	public static BracketMinDatetime getById(int id)
	{
		try
		{
			beginTransaction();
			
			BracketMinDatetime result = (BracketMinDatetime) getSession()
					.getNamedQuery("getBracketMinDatetimeById")
					.setInteger("id", id)
					.uniqueResult();
			
			commitTransaction();
			
			return result;
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}
	
}
